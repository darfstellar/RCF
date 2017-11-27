<cfif not variables.permission_type IS "Edit">
	<cfinclude template="unauthorized_page.cfm">
    <cfabort>
</cfif>

<cfquery name="contractor_contracts" datasource="#contractordb#">
	select contract_id, contract_number
    from contract
    where contract_status=1
    order by contract_number
</cfquery>

<cfquery name="contractor_companies" datasource="#contractordb#">
	select company_id, company_name
    from company
    where company_status=1
    order by company_name
</cfquery>

<cfquery name="security_companies" datasource="#contractordb#">
	select security_company_id, security_company_name
    from security_company
    where security_company_status=1
    order by security_company_name
</cfquery>

<cfquery name="security_cage_codes" datasource="#contractordb#">
	select security_cage_code_id, security_cage_code
    from security_cage_code
    order by security_cage_code
</cfquery>

<cfquery name="security_project_names" datasource="#contractordb#">
	select security_project_id, security_project_name
	from security_project
	where security_project_name != '' and security_project_name is not null
	order by security_project_name
</cfquery>

<cfquery name="security_cso" datasource="#contractordb#">
	select security_cso_id, security_cso_symbol, security_cso_location, security_cso_city, security_cso_state
	from security_cognizant_security_office
	order by security_cso_symbol
</cfquery>

<cfinclude template="states_include.cfm">
<html>
<head>
<title>Add New Contract</title>
<cfinclude template="meta.html">
<script src="/jquery/jquery-1.11.1.min.js"></script>
<script src="validateFields.js"></script>
<link rel="stylesheet" type="text/css" href="styles.css">
<style>
	#container {width: 700px;}
	.w {width: 160px;}
	.subordinate {border: dashed gray thin; border-radius: 5px; width: 500px; margin-left:50px; padding:4px;}
	.sw {width: 75px; text-align: right;}
	.ssubordinate {border: dashed gray thin; border-radius: 5px; width: 460px; margin-left:25px; padding:4px;}
	.ssw {width: 105px; text-align: right;}
	.ssw2 {width: 125px; text-align: right;}
</style>
<script src="js/contract_add.js"></script>
<script>
	locations = 0;
	locationTemplate = '<div class="mb5">\
			<div class="ib w"></div>\
			<div onClick="location_toggle(<INDEX>);" style="cursor: pointer;" class="ib">Location <INDEX> (Show/Hide)</div>\
		</div>\
		<div class="subordinate mb5" id="location_<INDEX>_toggle">\
			<div class="mb5">\
				<div class="ib ml5 s">Location <INDEX> Information</div>\
			</div>\
			<div class="mb5">\
            	<div class="ib ssw s">Cage Code<span id=cage_code_req_location_<INDEX>> *</span></div>\
				<div class="ib"><select name="cage_code_id_location_<INDEX>" id="cage_code_id_location_<INDEX>">\
					<option></option>\
					<cfoutput query="security_cage_codes"><option value="#security_cage_code_id#">#security_cage_code#</option></cfoutput>\
				</select></div>\
			</div>\
			<div class="mb5">\
				<div class="ib ssw s"></div>\
				<div class="ib">Cage Code Not in List<input type=checkbox name=cage_code_new_location_<INDEX> id=cage_code_new_location_<INDEX> onChange="toggle_cage_code(\'_location_<INDEX>\')"></div>\
			</div>\
			<div class="ssubordinate mb5 cage_code_toggle_location_<INDEX>">\
				<div class="mb5">\
					<div class="ib ml5 s">Cage Code Information</div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Cage Code *</div>\
					<div class="ib"><input name="cage_code_location_<INDEX>" id="cage_code_location_<INDEX>"></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Company</div>\
					<div class="ib"><select name="company_id_location_<INDEX>" id="company_id_location_<INDEX>">\
						<option></option>\
						<cfoutput query="security_companies"><option value="#security_company_id#">#security_company_name#</option></cfoutput>\
					</select></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s"></div>\
					<div class="ib">Company Not in List<input type=checkbox name=company_new_location_<INDEX> id=company_new_location_<INDEX> onChange="toggle_company(\'_location_<INDEX>\');"></div>\
				</div>\
				<div class="ssubordinate mb5 company_toggle_location_<INDEX>" style="width:420px;">\
					<div class="mb5">\
						<div class="ib s">Company Information</div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s" style="width: 75px;">Name *</div>\
						<div class="ib"><input name="company_name" id="company_name" size=50></div>\
					</div>\
					<div class="mb5">\
						<div class="ib s">Contractor DB Link</div>\
					</div>\
					<div class="mb5">\
						<div class="ib s" style="width: 75px; text-align: right;">Company</div>\
						<div class="ib"><select name="cdb_company_id" id="cdb_company_id">\
							<option></option>\
							<cfoutput query="contractor_companies"><cfset cname = left(company_name, 35)><cfif find(' (', cname) gt 0><cfset cname = trim(left(cname, find(' (', cname)))></cfif><option value="#company_id#">#cname#</option></cfoutput>\
						</select></div>\
					</div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Location *</div>\
					<div class="ib"><input name="company_name_location_<INDEX>" id="company_name_location_<INDEX>" size=50></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Address 1 *</div>\
					<div class="ib"><input name="address1_location_<INDEX>" id="address1_location_<INDEX>" size=50></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Address 2</div>\
					<div class="ib"><input name="address2_location_<INDEX>" id="address2_location_<INDEX>" size=50></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">City *</div>\
					<div class="ib"><input name="city_location_<INDEX>" id="city_location_<INDEX>" size=50></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">State *</div>\
					<cfset output=replace(state_dropdown("state_location_<INDEX>"), "'", '"', "ALL")>\
					<div class="ib"><cfoutput>#output#</cfoutput></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Zip Code *</div>\
					<div class="ib"><input name="zip_code_location_<INDEX>" id="zip_code_location_<INDEX>" size=11></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Phone</div>\
					<div class="ib"><input name="phone_location_<INDEX>" id="phone_location_<INDEX>" size=25></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Email</div>\
					<div class="ib"><input name="email_location_<INDEX>" id="email_location_<INDEX>" size=50></div>\
				</div>\
				<div class="mb5 s">Classified Mailing Address</div>\
				<div class="mb5">\
					<div class="ib s">Same as Above</div>\
					<div class="ib"><input type="checkbox" name="address_same_location_<INDEX>" id="address_same_location_<INDEX>"></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Address 1</div>\
					<div class="ib"><input name="classified_address1_location_<INDEX>" id="classified_address1_location_<INDEX>" size=50></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Address 2</div>\
					<div class="ib"><input name="classified_address2_location_<INDEX>" id="classified_address2_location_<INDEX>" size=50></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">City</div>\
					<div class="ib"><input name="classified_city_location_<INDEX>" id="classified_city_location_<INDEX>" size=50></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">State</div>\
					<cfset output=replace(state_dropdown("classified_state_location_<INDEX>"), "'", '"', "ALL")>\
					<div class="ib"><cfoutput>#output#</cfoutput></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Zip Code</div>\
					<div class="ib"><input name="classified_zip_code_location_<INDEX>" id="classified_zip_code_location_<INDEX>" size=11></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Phone</div>\
					<div class="ib"><input name="phone_location_<INDEX>" id="phone_location_<INDEX>" size=25></div>\
				</div>\
				<div class="mb5">\
					<div class="ib ssw s">Email</div>\
					<div class="ib"><input name="email_location_<INDEX>" id="email_location_<INDEX>" size=50></div>\
				</div>\
			</div>\
			<div class="mb5">\
            	<div class="ib ssw s">CSO <span id=cso_req_location_<INDEX>> *</span></div>\
				<div class="ib"><select name="cso_id_location_<INDEX>" id="cso_id_location_<INDEX>">\
					<option></option>\
					<cfoutput query="security_cso"><option value="#security_cso_id#">#security_cso_symbol# #security_cso_location#, #security_cso_city#, #security_cso_state#</option></cfoutput>\
				</select></div>\
			</div>\
			<div class="mb5">\
					<div class="ib ssw s"></div>\
					<div class="ib">CSO Not in List <input type=checkbox name=cso_new_location_<INDEX> id=cso_new_location_<INDEX> onChange="toggle_cso(\'_location_<INDEX>\')"></div>\
				</div>\
				<div class="ssubordinate mb5 cso_toggle_location_<INDEX>">\
					<div class="mb5">\
						<div class="ib s">CSO Information</div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">CSO Symbol *</div>\
						<div class="ib"><input name="cso_symbol_location_<INDEX>" id="cso_symbol_location_<INDEX>" size=50></div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">Location *</div>\
						<div class="ib"><input name="cso_location_location_<INDEX>" id="cso_location_location_<INDEX>" size=50></div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">Address 1 *</div>\
						<div class="ib"><input name="cso_address1_location_<INDEX>" id="cso_address1_location_<INDEX>" size=50></div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">Address 2</div>\
						<div class="ib"><input name="cso_address2_location_<INDEX>" id="cso_address2_location_<INDEX>" size=50></div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">City *</div>\
						<div class="ib"><input name="cso_city_location_<INDEX>" id="cso_city_location_<INDEX>" size=50></div>\
					</div>\
					<cfset output=replace(state_dropdown('cso_state_location_<INDEX>', ''), "'", '"', "ALL")>\
					<div class="mb5">\
						<div class="ib ssw s">State *</div>\
						<div class="ib"><cfoutput>#output#</cfoutput></div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">Zip Code *</div>\
						<div class="ib"><input name="cso_zip_code_location_<INDEX>" id="cso_zip_code_location_<INDEX>" size=11></div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">Phone *</div>\
						<div class="ib"><input name="cso_phone_location_<INDEX>" id="cso_phone_location_<INDEX>" size=25></div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">Fax</div>\
						<div class="ib"><input name="cso_fax_location_<INDEX>" id="cso_fax_location_<INDEX>" size=25></div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">Email</div>\
						<div class="ib"><input name="cso_email_location_<INDEX>" id="cso_email_location_<INDEX>" size=50></div>\
					</div>\
					<div class="mb5">\
						<div class="ib ssw s">Contact</div>\
						<div class="ib"><input name="cso_contact_location_<INDEX>" id="cso_contact_location_<INDEX>" size=50></div>\
					</div>\
				</div>\
			</div>\
		</div>';
	
	function location_toggle(index)
	{
		//alert('Got index: '+index);
		$('#location_'+index+'_toggle').toggle();
	}
	
	function add_location()
	{
		if (locations == 10)
		{
			alert('You have reached the limit of locations that can be added.');
			return false;
		}
		
		//console.log(locationTemplate.substring(1000).replace(/<INDEX>/g, ++locations));
		$('#locations').prepend(locationTemplate.replace(/<INDEX>/g, ++locations));
		$('.cage_code_toggle_location_'+locations).hide();
		$('.company_toggle_location_'+locations).hide();
		$('.cso_toggle_location_'+locations).hide();
	}
</script>
</head>
<body>

<div id="container">
	<cfinclude template="header.html">
    <div id=wrapper>
    <cfinclude template="menu.html">
    <div align="center"><h2 class=title>Add a New Contract</h2><hr /></div>
    <form action= "contract_edit.cfm" name="form1" method="post" onSubmit="return validation();">
	    <input type=hidden name=edit value="yes">
		<div class="pl50">
			<div class="mb10">Required Fields Marked *</div>
			<div class="mb5">
				<div class="ib w s">Contract Number *</div>
				<div class="ib"><input name="contract_number" id="contract_number" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Task Order Number</div>
				<div class="ib"><input name="task_order_number" id="task_order_number" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Company</div>
				<div class="ib"><select name="company_id" id="company_id">
					<option></option>
				<cfoutput query="security_companies">
					<option value="#security_company_id#">#security_company_name#</option>
				</cfoutput>
				</select></div>
			</div>
			<!-- TODO: Add company here if not in list above -->
			<div class="mb5">
				<div class="ib w s"></div>
				<div class="ib">Company Not in List<input type=checkbox name=company_new id=company_new onChange="toggle_company()"></div>
			</div>
			<div class="subordinate mb5 company_toggle" style="width:535px;">
				<div class="mb5">
					<div class="ib ml5 s">New Company</div>
				</div>
				<div class="mb5">
					<div class="ib sw s">Name *</div>
					<div class="ib"><input name="company_name" id="company_name" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib ml5 s">Contractor DB Link</div>
				</div>
				<div class="mb5">
					<div class="ib sw s">Company</div>
					<div class="ib"><select name="cdb_company_id" id="cdb_company_id">
						<option></option>
					<cfloop query="contractor_companies">
						<cfif find(' (', company_name) gt 0>
							<cfset cname = trim(left(company_name, find(' (', company_name)))>
						<cfelse>
							<cfset cname = company_name>
						</cfif>
						<cfoutput><option value="#company_id#">#cname#</option></cfoutput>
					</cfloop>
					</select></div>
				</div>
			</div>
			<div class="mb5">
				<div class="ib w s">Address Line 1 *</div>
				<div class="ib"><input name="address1" id="address1" size=50></div>
			</div>
			<div class="mb5">
				<div class="ib w s">Address Line 2</div>
				<div class="ib"><input name="address2" id="address2" size=50></div>
			</div>
			<div class="mb5">
				<div class="ib w s">City *</div>
				<div class="ib"><input name="city" id="city" size=50></div>
			</div>
			<div class="mb5">
				<div class="ib w s">State *</div>
				<cfset output=state_dropdown('state')>
				<div class="ib"><cfoutput>#output#</cfoutput></div>
			</div>
			<div class="mb5">
				<div class="ib w s">Zip Code *</div>
				<div class="ib"><input name="zip_code" id="zip_code" size=11></div>
			</div>
			<div class="mb5">
				<div class="ib w s">Phone</div>
				<div class="ib"><input name="phone" id="phone" size=25></div>
			</div>
			<div class="mb5">
				<div class="ib w s">Email</div>
				<div class="ib"><input name="email" id="email" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Cage Code</div>
				<div class="ib"><select name="cage_code_id_cage_code" id="cage_code_id_cage_code">
					<option></option>
				<cfoutput query="security_cage_codes">
					<option value="#security_cage_code_id#">#security_cage_code#</option>
				</cfoutput>
				</select></div>
			</div>
			<!-- TODO: Add cage code here if not in list above -->
			<div class="mb5">
				<div class="ib w s"></div>
				<div class="ib">Cage Code Not in List<input type=checkbox name=cage_code_new_cage_code id=cage_code_new_cage_code onChange="toggle_cage_code('_cage_code')"></div>
			</div>
			<div class="subordinate mb5 cage_code_toggle_cage_code">
				<div class="mb5">
					<div class="ib ml5 s">New Cage Code</div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Cage Code *</div>
					<div class="ib"><input name="cage_code_cage_code" id="cage_code_cage_code"></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Company</div>
					<div class="ib"><select name="company_id_cage_code" id="company_id_cage_code">
					<option></option>
					<cfoutput query="security_companies">
						<option value="#security_company_id#">#security_company_name#</option>
					</cfoutput>
					</select></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s"></div>
					<div class="ib">Company Not in List<input type=checkbox name=company_new_cage_code id=company_new_cage_code onChange="toggle_company('_cage_code')"></div>
				</div>
				<div class="ssubordinate mb5 company_toggle_cage_code" style="width:460px;">
					<div class="mb5">
						<div class="ib s">New Cage Code Company</div>
					</div>
					<div class="mb5">
						<div class="ib ssw s" style="width: 75px;">Name *</div>
						<div class="ib"><input name="company_name_cage_code" id="company_name_cage_code" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib s">Contractor DB Link</div>
					</div>
					<div class="mb5">
						<div class="ib s" style="width: 75px; text-align:right">Company</div>
						<div class="ib"><select name="cdb_company_id_cage_code" id="cdb_company_id_cage_code">
							<option></option>
							<cfoutput query="contractor_companies"><cfset cname = left(company_name, 40)><cfif find(' (', cname) gt 0><cfset cname = trim(left(cname, find(' (', cname)))></cfif><option value="#company_id#">#cname#</option></cfoutput>
						</select></div>
					</div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Location Name *</div>
					<div class="ib"><input name="company_name_cage_code" id="company_name_cage_code" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Address Line 1 *</div>
					<div class="ib"><input name="address1_cage_code" id="address1_cage_code" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Address Line 2</div>
					<div class="ib"><input name="address2_cage_code" id="address2_cage_code" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">City *</div>
					<div class="ib"><input name="city_cage_code" id="city_cage_code" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">State *</div>
					<cfset output=state_dropdown('state_cage_code')>
					<div class="ib"><cfoutput>#output#</cfoutput></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Zip Code *</div>
					<div class="ib"><input name="zip_code_cage_code" id="zip_code_cage_code" size=11></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Phone</div>
					<div class="ib"><input name="phone_cage_code" id="phone_cage_code" size=25></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Email</div>
					<div class="ib"><input name="email_cage_code" id="email_cage_code" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">CSO</div>
					<div class="ib"><select name="cso_id_cage_code" id="cso_id_cage_code">
					<option></option>
				<cfoutput query="security_cso">
					<option value="#security_cso_id#">#security_cso_symbol# #security_cso_location#, #security_cso_city#, #security_cso_state#</option>
				</cfoutput>
				</select></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s"></div>
					<div class="ib">CSO Not in List <input type=checkbox name=cso_new_cage_code id=cso_new_cage_code onChange="toggle_cso('_cage_code')"></div>
				</div>
				<div class="ssubordinate mb5 cso_toggle_cage_code">
					<div class="mb5">
						<div class="ib s">New Cage Code CSO</div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">CSO Symbol *</div>
						<div class="ib"><input name="cso_symbol_cage_code" id="cso_symbol_cage_code" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Location *</div>
						<div class="ib"><input name="cso_location_cage_code" id="cso_location_cage_code" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Address 1 *</div>
						<div class="ib"><input name="cso_address1_cage_code" id="cso_address1_cage_code" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Address 2</div>
						<div class="ib"><input name="cso_address2_cage_code" id="cso_address2_cage_code" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">City *</div>
						<div class="ib"><input name="cso_city_cage_code" id="cso_city_cage_code" size=50></div>
					</div>
					<cfset output=replace(state_dropdown('cso_state_cage_code', ''), "'", '"', "ALL")>
					<div class="mb5">
						<div class="ib ssw s">State *</div>
						<div class="ib"><cfoutput>#output#</cfoutput></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Zip Code *</div>
						<div class="ib"><input name="cso_zip_code_cage_code" id="cso_zip_code_cage_code" size=11></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Phone *</div>
						<div class="ib"><input name="cso_phone_cage_code" id="cso_phone_cage_code" size=25></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Fax</div>
						<div class="ib"><input name="cso_fax_cage_code" id="cso_fax_cage_code" size=25></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Email</div>
						<div class="ib"><input name="cso_email_cage_code" id="cso_email_cage_code" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Contact</div>
						<div class="ib"><input name="cso_contact_cage_code" id="cso_contact_cage_code" size=50></div>
					</div>
				</div>
				<div class="mb5 s">Classified Mailing Address</div>
				<div class="mb5">
					<div class="ib ssw2 s">Same as Above</div>
					<div class="ib"><input type='checkbox' name="address_same_cage_code" id="address_same_cage_code"></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Address Line 1</div>
					<div class="ib"><input name="classified_address1_cage_code" id="classified_address1_cage_code" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Address Line 2</div>
					<div class="ib"><input name="classified_address2_cage_code" id="classified_address2_cage_code" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">City</div>
					<div class="ib"><input name="classified_city_cage_code" id="classified_city_cage_code" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">State</div>
					<cfset output=state_dropdown('classified_state_cage_code')>
					<div class="ib"><cfoutput>#output#</cfoutput></div>
				</div>
				<div class="mb5">
					<div class="ib ssw2 s">Zip Code</div>
					<div class="ib"><input name="classified_zip_code_cage_code" id="classified_zip_code_cage_code" size=11></div>
				</div>
			</div>
			<div class="mb5">
				<div class="ib w s">DD254?</div>
				<div class="ib">
					<label for="dd254yes" class="strong_label">Yes</label><input type=radio value=yes name=dd254 id=dd254yes class="strong_label" onChange="toggle_flags(event);">
					<label for="dd254no" class="strong_label">No</label><input type=radio value=no name=dd254 id=dd254no class="strong_label" onChange="toggle_flags(event);">
				</div>
			</div>
			<!-- TODO: if 'yes' checked above, display flags and CSO below. Hidden otherwise -->
			<div class="subordinate mb5 dd254_toggle">
				<div class="mb5">
					<div class="ib ml5 s">DD254 Information</div>
				</div>
				<div class="mb5">
					<div class="ib sw s">Flags</div>
					<div class="ib">
						<label for="scg" class="strong_label">SCG</label><input type=checkbox name=scg id=scg class="strong_label">
						<label for="ppp" class="strong_label">PPP</label><input type=checkbox name=ppp id=ppp class="strong_label">
						<label for="ci" class="strong_label">CI</label><input type=checkbox name=ci id=ci class="strong_label">
						<label for="10e1" class="strong_label">10e(1)</label><input type=checkbox name=10e1 id=10e1 class="strong_label">
						<label for="10e2" class="strong_label">10e(2)</label><input type=checkbox name=10e2 id=10e2 class="strong_label">
						<label for="10f" class="strong_label">10f</label><input type=checkbox name=10f id=10f class="strong_label">
					</div>
				</div>
				<div class="mb5">
					<div class="ib sw s">CSO<span id=cso_req_dd254> *</span></div>
					<div class="ib"><select name="cso_id_dd254" id="cso_id_dd254">
						<option></option>
						<cfoutput query="security_cso">
						<option value="#security_cso_id#">#security_cso_symbol# #security_cso_location#, #security_cso_city#, #security_cso_state#</option>
						</cfoutput>
					</select></div>
				</div>
				<div class="mb5">
					<div class="ib sw s"></div>
					<div class="ib">CSO Not in List <input type=checkbox name=cso_new_dd254 id=cso_new_dd254 onChange="toggle_cso('_dd254')"></div>
				</div>
				<div class="ssubordinate mb5 cso_toggle_dd254">
					<div class="mb5">
						<div class="ib ml5 s">New DD254 CSO</div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">CSO Symbol *</div>
						<div class="ib"><input name="cso_symbol_dd254" id="cso_symbol_dd254" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Location *</div>
						<div class="ib"><input name="cso_location_dd254" id="cso_location_dd254" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Address 1 *</div>
						<div class="ib"><input name="cso_address1_dd254" id="cso_address1_dd254" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Address 2</div>
						<div class="ib"><input name="cso_address2_dd254" id="cso_address2_dd254" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">City *</div>
						<div class="ib"><input name="cso_city_dd254" id="cso_city_dd254" size=50></div>
					</div>
					<cfset output=state_dropdown('cso_state_dd254', '')>
					<div class="mb5">
						<div class="ib ssw s">State *</div>
						<div class="ib"><cfoutput>#output#</cfoutput></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Zip Code *</div>
						<div class="ib"><input name="cso_zip_code_dd254" id="cso_zip_code_dd254" size=11></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Phone *</div>
						<div class="ib"><input name="cso_phone_dd254" id="cso_phone_dd254" size=25></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Fax</div>
						<div class="ib"><input name="cso_fax_dd254" id="cso_fax_dd254" size=25></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Email</div>
						<div class="ib"><input name="cso_email_dd254" id="cso_email_dd254" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib ssw s">Contact</div>
						<div class="ib"><input name="cso_contact_dd254" id="cso_contact_dd254" size=50></div>
					</div>
				</div>
			</div>
			<div class="mb5">
				<div class="ib w s">Work Location</div>
				<div class="ib">
					<label for="onbase" class="strong_label">On Base</label><input type=radio name=onbase value=yes id=onbase class="strong_label" onChange="toggle_onbase();">
					<label for="offbase" class="strong_label">Off Base</label><input type=radio name=onbase value=no id=offbase class="strong_label" onChange="toggle_onbase();">
				</div>
			</div>
			<!-- TODO: if 'onbase' checked above, show CDB below. Hidden otherwise -->
			<div class="subordinate mb5 onbase_toggle">
				<div class="mb5">
					<div class="ib ml5 s">Contractor DB Link</div>
				</div>
				<div class="mb5 onbase_toggle">
					<div class="ib sw s">Contract</div>
					<div class="ib"><select name="cdb_contract_id" id="cdb_contract_id">
						<option></option>
					<cfoutput query="contractor_contracts">
						<option value="#contract_id#">#contract_number#</option>
					</cfoutput>
					</select></div>
				</div>
			</div>
			<div class="mb5">
				<div class="ib w s">Subcontractor</div>
				<div class="ib">
					<label for="subcontractoryes" class="strong_label">Yes</label><input type=radio name=subcontractor value=yes id=subcontractoryes class="strong_label" onChange="toggle_subcontractor();">
					<label for="subcontractorno" class="strong_label">No</label><input type=radio name=subcontractor value=no id=subcontractorno class="strong_label" onChange="toggle_subcontractor();">
				</div>
			</div>
			<div class="subordinate mb5 subcontractor_toggle">
				<div class="mb5">
					<div class="ib ml5 s">Subcontractor Prime Information</div>
				</div>
				<div class="mb5">
					<div class="ib w s">Prime Contract # *</div>
					<div class="ib"><input name="prime_contract_number" id="prime_contract_number" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib w s">Task Order #</div>
					<div class="ib"><input name="prime_task_order_number" id="prime_task_order_number" size=50></div>
				</div>
				<div class="mb5">
					<div class="ib w s">Prime Contractor<span id=company_id_req_subcontractor> *</span></div>
					<div class="ib"><select name="company_id_subcontractor" id="company_id_subcontractor">
						<option></option>
					<cfoutput query="security_companies">
						<option value="#security_company_id#">#security_company_name#</option>
					</cfoutput>
					</select></div>
				</div>
				<!-- TODO: Add company here if not in list above -->
				<div class="mb5">
					<div class="ib w s"></div>
					<div class="ib">Company Not in List<input type=checkbox name=company_new_subcontractor id=company_new_subcontractor onChange="toggle_company('_subcontractor')"></div>
				</div>
				<div class="ssubordinate mb5 company_toggle_subcontractor" style="width:440px;">
					<div class="mb5">
						<div class="ib s">New Subcontractor Primary Company</div>
					</div>
					<div class="mb5">
						<div class="ib ssw s" style="width: 75px;">Name *</div>
						<div class="ib"><input name="company_name_subcontractor" id="company_name_subcontractor" size=50></div>
					</div>
					<div class="mb5">
						<div class="ib s">Contractor DB Link</div>
					</div>
					<div class="mb5">
						<div class="ib s" style="width: 75px; text-align:right">Company</div>
						<div class="ib"><select name="cdb_company_id_subcontractor" id="cdb_company_id_subcontractor">
							<option></option>
							<cfoutput query="contractor_companies"><cfset cname = left(company_name, 38)><cfif find(' (', cname) gt 0><cfset cname = trim(left(cname, find(' (', cname)))></cfif><option value="#company_id#">#cname#</option></cfoutput>
						</select></div>
					</div>
				</div>
			</div>
			<div class="mb5">
				<div class="ib w s">Add Location</div>
				<div class="ib"><div onClick="add_location();" style="cursor: pointer;">Click here</div></div>
			</div>
			<!-- TODO: adding location template here -->
			<div id="locations">
			</div>
			<div class="mb5">
            	<div class="ib w s">Contract Status *</div>
				<div class="ib"><select name="contract_status" id="contract_status">
					<option></option>
					<option value='1' selected>Active</option>
					<option value='0'>Inactive</option>
				</select></div>
			</div>
			<div class="mb5">
				<div class="ib w s">Assigned Project(s)</div>
				<div class="ib"><select name="project_name" id="project_name" multiple size=5>
				<cfoutput query="security_project_names">
					<option value="#security_project_id#">#security_project_name#</option>
				</cfoutput>
				</select></div>
			</div>
			<div class="mt10"><input type="submit" value="Submit"></div>
			</div>
		</form>
	</div>
</div>

<cfinclude template="footer.html">
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
</body>
</html>

