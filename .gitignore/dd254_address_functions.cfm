<!--- The contractor/sub/location address is usually straightforward to figure out *knock on wood* --->
<cffunction access="public" output="false" returntype="struct" name="parseLocationAddress">
	<cfargument required="true" type="array" name="lines">
	
	<cfset address = {
		name = '',
		address = '',
		suite = '',
		city = '',
		state = '',
		zip = ''
	}>
	
	<!--- The first line will have the name, the next will have the street address, the last line will have the city, state and zip	
		and if there are 3 sublines, the middle one will be suite number --->
	<cfset address.name = lines[1]>
	<cfset address.address = lines[2]>
	<cfif arraylen(lines) gt 3>
		<cfset address.suite = lines[3]>
		<cfset location = listToArray(lines[4])>
	<cfelse>
		<cfset location = listToArray(lines[3])>
	</cfif>
	<!--- If the city/state/zip (location) has a comma, process it here --->
	<cfif arraylen(location) eq 2>
		<cfset address.city = location[1]>
		<cfset more = listToArray(location[2], ' ')>
		<cfset address.zip = more[2]>
		<cfset address.state = more[1]>
	<!--- Otherwise, do it the hard way --->
	<cfelse>
		<cfset more = listToArray(reverse(lines[3]), ' ')>
		<!--- the zip code is the last word on the line --->
		<cfset address.zip = reverse(more[1])>
		<!--- The state is the next to last word --->
		<cfset address.state = reverse(more[2])>
		<!--- Everything else is the city name --->
		<cfset city = ''>
		<cfloop from="3" to="#arraylen(more)#" index="i">
			<cfset city = city & "#(more[i])# ">
		</cfloop>
		<cfset address.city = reverse(city)>
	</cfif>
	
	<cfreturn address>
</cffunction>

<!--- The Cognizant Security Office (CSO) address can be in a variety of formats so try and break it up into parts --->
<cffunction access="public" output="false" returntype="struct" name="parseCsoAddress">
	<cfargument required="true" type="array" name="lines">
	
	<cfset address = {
		name = '',
		address = '',
		suite = '',
		city = '',
		state = '',
		zip = '',
		phone = '',
		fax = '',
		email = '',
		foc = ''
	}>

	<cfif find("(", lines[1])>
		<cfset address.name = lines[1]>
		<cfset more = listToArray(lines[2])>
		<!--- Depending on where the address starts, keep track of where to start processing once we're past the address --->
		<cfset theRest = 2>
	<cfelseif find("(", lines[2])>
		<cfset address.name = lines[2]>
		<cfset more = listToArray(lines[3])>
		<!--- Depending on where the address starts, keep track of where to start processing once we're past the address --->
		<cfset theRest = 3>
	</cfif>
	<!--- Sometimes the address parts have commas, sometimes not --->
	<cfif arraylen(more) eq 2>
		<cfset address.address = more[1]>
		<cfset address.suite = more[2]>
		<!--- Sometimes the entire address is on one line. Decide based on how many words are in the suite name. If more than 2 words (e.g. Suite 401), assume full address --->
		<cfif arraylen(listToArray(address.suite, ' ')) gt 2>
			<cfset temp = listToArray(address.suite, ' ')>
			<cfset address.suite = temp[1] & ' ' & temp[2]>
			<cfset location[1] = temp[3]>
			<cfset location[2] = ''>
			<cfloop from="4" to="#arraylen(temp)#" index="i">
				<cfset location[2] = location[2] & ' ' &temp[i]>
			</cfloop>
			<!--- If the entire address is in 2 lines, start further processing at line 3 --->
			<cfset theRest = theRest + 3 - theRest>
		<cfelse>
			<!--- If the address is in 3 lines, start further processing at line 4 --->
			<cfset theRest = theRest + 4 - theRest>
			<cfset location = listToArray(lines[theRest])>
		</cfif>
		<cfset address.city = location[1]>
		<cfif arraylen(location) gte 2>
			<cfset more = listToArray(location[2], ' ')>
			<cfset address.zip = more[2]>
			<cfset address.state = more[1]>
		<!--- Sometimes the address is so badly mangled I just can't figure it out --->
		<cfelse>
			<cfset address.zip = '00000'>
			<cfset address.state = 'NA'>
		</cfif>
	<cfelse>
		<cfset address.address = more[1]>
		<cfif arraylen(more) eq 3>
			<cfset location = listToArray(more[3], ' ')>
			<cfset address.zip = location[2]>
			<cfset address.state = location[1]>
			<cfif more[2] contains 'Suite' or more[2] contains 'Ste'>
				<cfset more2 = listToArray(more[2], ' ')>
				<cfset address.suite = more2[1] & ' ' & more2[2]>
				<cfset address.city = ''>
				<cfloop from="3" to="#arraylen(more2)#" index="i">
					<cfset address.city = address.city & "#more2[i]# ">
				</cfloop>
			</cfif>
		<!--- Sometimes the entire address is on one line but with the odd comma --->
		<cfelseif arraylen(more) gte 4>
			<cfset address.suite = more[2]>
			<cfset address.city = more[3]>
			<cfset more2 = listToArray(more[4], ' ')>
			<cfset address.zip = more2[2]>
			<cfset address.state = more2[1]>
		</cfif>
		<!--- If the entire address is in 2 lines, start further processing at line 3 --->
		<cfset theRest = theRest = theRest + 3 - theRest>
	</cfif>
	
	<!--- Now find data for phone, main, fax, email, or field office chief in the rest of the lines --->
	<cfset totalLines = arraylen(lines)>
	<!--- Loop over the rest of the lines not already processed and pick out parts as (if) I find them --->
	<cfloop from="#theRest#" to="#arraylen(lines)#" index="i">
		<cfif FindNoCase('Phone', lines[i])>
			<!--- Sometimes the email label is on the same line as the phone due to limited space in the text box --->
			<cfif FindNoCase('Email', lines[i])>
				<!--- Grab the email and then remove it from the line with the phone number --->
				<cfset temp = right(lines[i], len(lines[i]) - FindNoCase('Email', lines[i])+1)>
				<cfif not find('@', temp) and arraylen(lines) gte #i#+1 and find('@', lines[i+1])>
					<cfset temp = temp & " " & lines[i+1]>
				</cfif>
				<cfset address.email = parseLine(temp, 'Email')>
				<cfset lines[i] = left(lines[i], FindNoCase('Email', lines[i])-1)>
			</cfif>
			<cfset address.phone = parseLine(lines[i], 'Phone')>
		<cfelseif FindNoCase('Main', lines[i])>
			<!--- Sometimes the fax label is on the same line as the main due to limited space in the text box --->
			<cfif FindNoCase('Fax', lines[i])>
				<!--- Grab the fax number and remove it from the line with the main phone number --->
				<cfset address.fax = parseLine(right(lines[i], len(lines[i]) - FindNoCase('Fax', lines[i])+1), 'Fax')>
				<cfset lines[i] = left(lines[i], FindNoCase('Fax', lines[i])-1)>
			</cfif>
			<cfset address.phone = parseLine(lines[i], 'Main')>
		<cfelseif FindNoCase('Fax', lines[i])>
			<cfset address.fax = parseLine(lines[i], 'Fax')>
		<cfelseif FindNoCase('Office', lines[i])>
			<cfset address.phone = parseLine(lines[i], 'Office')>
		<cfelseif FindNoCase('Email', lines[i])>
			<!--- Sometimes the email label is alone on a line and the email address is on the next line (if there is a next line) --->
			<cfif len(lines[i]) lt 10 and arraylen(lines) gte #i#+1 and find('@', lines[i+1])>
				<cfset address.email = trim(lines[i+1])>
			<cfelse>
				<cfset address.email = parseLine(lines[i], 'Email')>
			</cfif>
		<cfelseif FindNoCase('Field Office', lines[i])>
			<cfset address.foc = parseLine(lines[i], 'Field Office Chief')>
		</cfif>
	 </cfloop>
	 
	 <cfreturn address>
</cffunction>

<!--- Return the information in the received line of text, minus the label of the type 
	(e.g. line='Phone: 555-555-0000' and type='Phone', remove 'Phone: ' and return '555-555-0000') --->
<cffunction access="public" output="no" returntype="string" name="parseLine">
	<cfargument required="true" type="string" name="line">
	<cfargument required="true" type="string" name="type">
	
	<cfif FindNoCase(type, line)>
		<!--- Sometimes there is a colon and sometimes not --->
		<cfif Find(':', line)>
			<cfreturn trim(right(line, len(line)-Find(':', line)))>
		<cfelse>
			<cfreturn trim(right(line, len(line)-FindNoCase(type, line)-len(type)))>
		</cfif>
	</cfif>
</cffunction>