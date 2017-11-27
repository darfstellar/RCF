<cfinclude template="dd254_address_functions.cfm">

<cftry>
	<!--- opens a PDF document and parses information from it --->
    <cfpdfform action="read" source= "./AFSIM_DD-254 BAE working (17-334-RQ-01ITA) Rev. 1.pdf" result="formData" />
    <cfoutput>
        <cfif trim(len(formData['prime_no'])) gt 0>
        Using Primary Contract Number: #formData['prime_no']#<br>
        </cfif>
        <cfif trim(len(formData['sub_no'])) gt 0>
        Using Subcontract Number: #formData['sub_no']#<br>
        </cfif>
        <cfif trim(len(formData['solic_no'])) gt 0>
        Using Solicitation or Other Number: #formData['solic_no']#<br>
        </cfif>
    
        <cfif trim(len(formData['ctr_cage'])) gt 3>
            Contractor Cage code: #formData['ctr_cage']#<br><br>
            <!--- break the address by newlines --->
            <cfset address = parseLocationAddress(listToArray(formData['ctr_name'], chr(13)))>
            
            Contractor Location:<br>
            Name: #address.name#<br>
            Street address: #address.address#<br>
            <cfif len(address.suite) gt 0>Address 2: #address.suite#<br></cfif>
            City: #address.city#<br>
            State: #address.state#<br>
            Zip: #address.zip#<br><br>
        
            <cfset address = parseCsoAddress(listToArray(formData['ctr_ofc'], chr(13)))>
        
            CSO:<br>
            Name: #address.name#<br>
            Street address: #address.address#<br>
            <cfif len(address.suite) gt 0>Address 2: #address.suite#<br></cfif>
            City: #address.city#<br>
            State: #address.state#<br>
            Zip: #address.zip#<br>
            <cfif len(address.phone) gt 0>Phone: #address.phone#<br></cfif>
            <cfif len(address.fax) gt 0>Fax: #address.fax#<br></cfif>
            <cfif len(address.email) gt 0>Email: #address.email#<br></cfif>
            <cfif len(address.foc) gt 0>Field Office Chief: #address.foc#<br></cfif>
        </cfif>
        
        <cfif trim(len(formData['sub_cage'])) gt 3>
            Subcontractor Cage Code: #formData['sub_cage']#<br><br>
           
            <cfset address = parseLocationAddress(listToArray(formData['sub_name'], chr(13)))>
            
            Subcontractor Location:<br>
            Name: #address.name#<br>
            Street address: #address.address#<br>
            <cfif len(address.suite) gt 0>Address 2: #address.suite#<br></cfif>
            City: #address.city#<br>
            State: #address.state#<br>
            Zip: #address.zip#<br><br>
    
            <cfset address = parseCsoAddress(listToArray(formData['sub_ofc'], chr(13)))>
    
            CSO:<br>
            Name: #address.name#<br>
            Street address: #address.address#<br>
            <cfif len(address.suite) gt 0>Address 2: #address.suite#<br></cfif>
            City: #address.city#<br>
            State: #address.state#<br>
            Zip: #address.zip#<br>
            <cfif len(address.phone) gt 0>Phone: #address.phone#<br></cfif>
            <cfif len(address.fax) gt 0>Fax: #address.fax#<br></cfif>
            <cfif len(address.email) gt 0>Email: #address.email#<br></cfif>
            <cfif len(address.foc) gt 0>Field Office Chief: #address.foc#<br></cfif>
        </cfif>
        
        <cfif trim(len(formData['perf_cage'])) gt 3>
            Performance Cage Code: #formData['perf_cage']#<br><br>
            
            <cfset address = parseLocationAddress(listToArray(formData['perf_loc'], chr(13)))>
           
            Performance Location:<br>
            Name: #address.name#<br>
            Street address: #address.address#<br>
            <cfif len(address.suite) gt 0>Address 2: #address.suite#<br></cfif>
            City: #address.city#<br>
            State: #address.state#<br>
            Zip: #address.zip#<br><br>
    
            <cfset address = parseCsoAddress(listToArray(formData['perf_ofc'], chr(13)))>
    
            CSO:<br>
            Name: #address.name#<br>
            Street address: #address.address#<br>
            <cfif len(address.suite) gt 0>Address 2: #address.suite#<br></cfif>
            City: #address.city#<br>
            State: #address.state#<br>
            Zip: #address.zip#<br>
            <cfif len(address.phone) gt 0>Phone: #address.phone#<br></cfif>
            <cfif len(address.fax) gt 0>Fax: #address.fax#<br></cfif>
            <cfif len(address.email) gt 0>Email: #address.email#<br></cfif>
            <cfif len(address.foc) gt 0>Field Office Chief: #address.foc#<br></cfif>
        </cfif>
	</cfoutput>

	<cfcatch type = "any"> 
        <!--- The message to display. ---> 
        <h3>Oops!</h3> 
        <cfoutput> 
            <!--- The diagnostic message from ColdFusion. ---> 
            <p>Caught an exception, type = #CFCATCH.TYPE#</p> 
            <p>#cfcatch.message#</p> 
            <cfif len(cfcatch.detail) gt 0>
            <p>The details are:</p> 
            #cfcatch.detail#"
            </cfif>
        </cfoutput> 
    </cfcatch> 

</cftry>