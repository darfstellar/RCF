<cfif not variables.permission_type IS "Edit">
	<cfinclude template="unauthorized_page.cfm">
    <cfabort>
</cfif>

<html>
<head>
<title>Parse a DD254</title>
<cfinclude template="meta.html">
<script src="validateFields.js"></script>
<script>
	function pruneFields(reqFields, multiFields)
	{
		// the form fields associated with each section of the contract
		var contract_ignore_req = ['contract_status'];
		var contract_ignore_multi = ['contract_number','subcontract_number','other_number'];
		var ccso_ignore_req = ['contractor_cso_symbol', 'contractor_cso_location', 'contractor_cso_address1', 'contractor_cso_city', 'contractor_cso_state', 'contractor_cso_zip_code', 'contractor_cso_phone'];
		var ccc_ignore_req = ['contractor_cage_code', 'contractor_address1', 'contractor_city', 'contractor_state', 'contractor_zip_code'];
		var scc_ignore_req = ['subcontractor_cage_code', 'subcontractor_address1', 'subcontractor_city', 'subcontractor_state', 'subcontractor_zip_code'];
		var scso_ignore_req = ['subcontractor_cso_symbol', 'subcontractor_cso_location', 'subcontractor_cso_address1', 'subcontractor_cso_city', 'subcontractor_cso_state', 'subcontractor_cso_zip_code', 'subcontractor_cso_phone'];
		var pcc_ignore_req = ['performance_cage_code', 'performance_address1', 'performance_city', 'performance_state', 'performance_zip_code'];
		var pcso_ignore_req = ['performance_cso_symbol', 'performance_cso_location', 'performance_cso_address1', 'performance_cso_city', 'performance_cso_state', 'performance_cso_zip_code', 'performance_cso_phone'];
		
		// if any form section is ignored, remove the associated required fields from being checked before the form can be submitted
		if (document.getElementById("contract_ignore") && document.getElementById("contract_ignore").checked)
		{
			reqFields = reqFields.filter(function(x) {return contract_ignore_req.indexOf(x) < 0;});
			multiFields = multiFields.filter(function(x) {return contract_ignore_multi.indexOf(x) < 0;});
		}
		
		if (document.getElementById("ccso_ignore") && document.getElementById("ccso_ignore").checked)
		{
			reqFields = reqFields.filter(function(x) {return ccso_ignore_req.indexOf(x) < 0;});
		}
		
		if (document.getElementById("ccc_ignore") && document.getElementById("ccc_ignore").checked)
		{
			reqFields = reqFields.filter(function(x) {return ccc_ignore_req.indexOf(x) < 0;});
		}
		
		if (document.getElementById("scc_ignore") && document.getElementById("scc_ignore").checked)
		{
			reqFields = reqFields.filter(function(x) {return scc_ignore_req.indexOf(x) < 0;});
		}
		
		if (document.getElementById("scso_ignore") && document.getElementById("scso_ignore").checked)
		{
			reqFields = reqFields.filter(function(x) {return scso_ignore_req.indexOf(x) < 0;});
		}
		
		if (document.getElementById("pcc_ignore") && document.getElementById("pcc_ignore").checked)
		{
			reqFields = reqFields.filter(function(x) {return pcc_ignore_req.indexOf(x) < 0;});
		}
		
		if (document.getElementById("pcso_ignore") && document.getElementById("pcso_ignore").checked)
		{
			reqFields = reqFields.filter(function(x) {return pcso_ignore_req.indexOf(x) < 0;});
		}
		
		return validateFields(reqFields, multiFields);
	}
</script>
<link rel="stylesheet" type="text/css" href="styles.css">
<style>
#container{width:900px;}
#wrapper {padding: 15px;}
.w {width: 240px;}
</style>
</head>

<body>

<div id="container">
	<cfinclude template="header.html">
    <div id=wrapper>
    <cfinclude template="menu.html">
    <div align="center"><h2 class=title>Process a DD254</h2><hr></div>

	<cfset contractNumber=''>
	<cfset contractType=''>
	<cfset contractorCageCode=''>
	<cfset subcontractorCageCode=''>
	<cfset performanceCageCode=''>
	<cfset contractorCageCodeAddress=''>
	<cfset subcontractorCageCodeAddress=''>
	<cfset performanceCageCodeAddress=''>
	<cfset contractorCsoAddress=''>
	<cfset subcontractorCsoAddress=''>
	<cfset performanceCsoAddress=''>
	<cfset contractorCsoSymbol=''>
	<cfset subcontractorCsoSymbol=''>
	<cfset performanceCsoSymbol=''>
	<cfset submit=0>
	<cftry>
		<cfif structKeyExists(form, 'filedata1')>
			<cfset tempDir = getTempDirectory()>
			<cfset input = form.filedata1.Split(',')>
			<cfset myfilename = input[1]>
			<cfset contents = ToBinary(input[3])>
			<cffile action="write" file="#tempDir#/#myfilename#" nameconflict="overwrite" output="#contents#">
			
			<!--- opens a PDF document and parses information from it --->
			<cfpdfform action="read" source="#tempDir#/#myfilename#" result="formData" />
			<!---<cfdump var="#formData#" label="Result">--->
			
			<cfoutput>
			<ul>
				<li>Processing file: '#myfilename#'<br><br></li>
				<cfif structKeyExists(formData, 'prime_no')>
					<cfinclude template="dd254_address_functions.cfm">
					
					<cfif trim(len(formData['prime_no'])) gt 0>
						<cfquery name="security_contracts" datasource="#contractordb#">
							select security_contract_id
							from security_contract
							where security_contract_number='#formData['prime_no']#'
						</cfquery>
						<cfif #security_contracts.RecordCount# gt 0>
							<li>Contract #formData['prime_no']# is already in the database.</li>
						<cfelse>
							<cfset contractType='number'>
							<cfset contractNumber=formData['prime_no']>
						</cfif>
					
					<cfelseif trim(len(formData['sub_no'])) gt 0>
						<cfquery name="security_contracts" datasource="#contractordb#">
							select security_contract_id
							from security_contract
							where security_contract_subcontract_number='#formData['sub_no']#'
						</cfquery>
						<cfif #security_contracts.RecordCount# gt 0>
							<li>Contract #formData['sub_no']# is already in the database.</li>
						<cfelse>
							<cfset contractType='subcontract_number'>
							<cfset contractNumber=formData['sub_no']>
						</cfif>
					
					<cfelseif trim(len(formData['solic_no'])) gt 0>
						<cfquery name="security_contracts" datasource="#contractordb#">
							select security_contract_id
							from security_contract
							where security_contract_other_number='#formData['solic_no']#'
						</cfquery>
						<cfif #security_contracts.RecordCount# gt 0>
							<li>Contract #formData['solic_no']# is already in the database.</li>
						<cfelse>
							<cfset contractType='other_number'>
							<cfset contractNumber=formData['solic_no']>
						</cfif>
					</cfif>
					
					<cfif trim(len(formData['ctr_cage'])) gt 3>
						<!--- break the address by newlines --->
						<cfquery name="security_cage_codes" datasource="#contractordb#">
							select security_cage_code_id
							from security_cage_code
							where security_cage_code='#formData['ctr_cage']#'
						</cfquery>
						<cfif #security_cage_codes.RecordCount# gt 0>
							<cfset contractorCageCode=formData['ctr_cage']>
							<li>Cage code #formData['ctr_cage']# is already in the database.</li>
						<cfelse>
							<cfset contractorCageCodeAddress = parseLocationAddress(listToArray(formData['ctr_name'], chr(13)))>
						</cfif>

						<cfif trim(len(formData['ctr_ofc'])) gt 3>
							<cfset contractorCsoAddress = parseCsoAddress(listToArray(formData['ctr_ofc'], chr(13)))>
							<cfset symbol = trim(reReplace(contractorCsoAddress.name, ".+\((.*)\)", "\1", "ALL"))>
							<cfquery name="security_csos" datasource="#contractordb#">
								select security_cso_id, security_cso_location
								from security_cognizant_security_office
								where security_cso_symbol='#symbol#'
							</cfquery>
							<cfif #security_csos.RecordCount# gt 0>
								<cfset contractorCsoSymbol=symbol>
								<li>CSO: #contractorCsoAddress.name# is already in the database
								<cfif contractorCsoAddress.name neq security_csos.security_cso_location>
								 as '#security_csos.security_cso_location# (#symbol#)'
								 </cfif>
								.</li>
							</cfif>
						</cfif>
					</cfif>

					<cfif trim(len(formData['sub_cage'])) gt 3>
						<cfquery name="security_cage_codes" datasource="#contractordb#">
							select security_cage_code_id
							from security_cage_code
							where security_cage_code='#formData['sub_cage']#'
						</cfquery>
						<cfif #security_cage_codes.RecordCount# gt 0>
						<cfset subcontractorCageCode=formData['sub_cage']>
							<li>Cage code #formData['sub_cage']# is already in the database.</li>
						<cfelse>
							<cfset subcontractorCageCodeAddress = parseLocationAddress(listToArray(formData['sub_cage'], chr(13)))>
						</cfif>
					
						<cfif trim(len(formData['sub_ofc'])) gt 3>
							<cfset subcontractorCsoAddress = parseCsoAddress(listToArray(formData['sub_ofc'], chr(13)))>
							<cfset symbol = reReplace(subcontractorCsoAddress.name, ".+\((.*)\)", "\1", "ALL")>
							<cfquery name="security_csos" datasource="#contractordb#">
								select security_cso_id, security_cso_location
								from security_cognizant_security_office
								where security_cso_symbol='#symbol#'
							</cfquery>
							<cfif #security_csos.RecordCount# gt 0>
								<cfset subcontractorCsoSymbol=symbol>
								<li>CSO: #subcontractorCsoAddress.name# is already in the database
								<cfif subcontractorCsoAddress.name neq security_csos.security_cso_location>
								 as '#security_csos.security_cso_location# (#symbol#)'
								 </cfif>
								 .</li>
							</cfif>
						</cfif>
					</cfif>

					<cfif trim(len(formData['perf_cage'])) gt 3>
						<cfquery name="security_cage_codes" datasource="#contractordb#">
							select security_cso_location
							from security_cage_code
							where security_cage_code='#formData['perf_cage']#'
						</cfquery>
						<cfif #security_cage_codes.RecordCount# gt 0>
							<cfset performanceCageCode=formData['perf_cage']>
							<li>Cage code #formData['perf_cage']# is already in the database.</li>
						<cfelse>
							<cfset performanceCageCodeAddress = parseLocationAddress(listToArray(formData['perf_loc'], chr(13)))>
						</cfif>
					
						<cfif trim(len(formData['perf_ofc'])) gt 15>
							<cfset performanceCsoAddress = parseCsoAddress(listToArray(formData['perf_ofc'], chr(13)))>
							<cfset symbol = reReplace(performanceCsoAddress.name, ".+\((.*)\)", "\1", "ALL")>
							<cfquery name="security_csos" datasource="#contractordb#">
								select security_cso_id, security_cso_location
								from security_cognizant_security_office
								where security_cso_symbol='#symbol#'
							</cfquery>
							<cfif #security_csos.RecordCount# gt 0>
								<cfset performanceCsoSymbol=symbol>
								<li>CSO: #performanceCsoAddress.name# is already in the database
								<cfif performanceCsoAddress.name neq security_csos.security_cso_location>
								 as '#security_csos.security_cso_location# (#symbol#)'
								 </cfif>
								 .</li>
							</cfif>
						</cfif>
					</cfif>
				<cfelse>
					I do not recognize this document. I can only process DD 254s as PDF documents with active form fields, not digitally signed copies.<br>
				</cfif>
			</cfoutput>
	
			<!--- Delete the PDF file after processing it --->
			<cffile action="delete" file="#myfilename#">
		<cfelse>
			<cfoutput>I got no data. Try again.<br></div></cfoutput>
			<cfexit>
		</cfif>
		</ul>
	
		<cfquery name="security_contracts" datasource="#contractordb#">
			select security_contract_id, isnull(security_contract_number, isnull(security_contract_subcontract_number, isnull(security_contract_other_number, 'None'))) as cn
			from security_contract
			where security_contract_status=1
			order by security_contract_number
		</cfquery>
		
		<cfquery name="contractor_contracts" datasource="#contractordb#">
			select contract_id, contract_number
			from contract
			where contract_status=1
			order by contract_number
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
	
		<cfquery name="security_cso" datasource="#contractordb#">
			select security_cso_id, security_cso_symbol, security_cso_location, security_cso_city, security_cso_state
			from security_cognizant_security_office
			order by security_cso_symbol
		</cfquery>

		<cfquery name="security_project_names" datasource="#contractordb#">
			select security_project_id, security_project_name
			from security_project
			where security_project_name != '' and security_project_name is not null
			order by security_project_name
		</cfquery>

		<cfinclude template="states_include.cfm">
		<!---  These arrays will hold field names for fields that require values depending on which items are being inserted into the database.
				There can be any combination of contract, cage code (3 types) or CSO (3 types) for a total of 7 possible items. Any can exist
				without the other if some already exist in the database, but the others can be inserted if needed. CF arrays will be turned
				into javascript arrays at the end for use by form onSubmit() to check form field values --->
		<cfset fieldsRequired = arrayNew(1)>
		<cfset someOfFieldsRequired = arrayNew(1)>
		
	<form action= "dd254_process.cfm" name="form1" method="post"  onSubmit="return pruneFields(getFieldsRequired(), getSomeOfFieldsRequired());">
	    <input type=hidden name=edit value="yes">
		<cfif len(contractNumber) gt 0>
			<cfset submit=1>
			<cfset junk = arrayAppend(fieldsRequired, ['contract_status'], true)>
			<cfset junk = arrayAppend(someOfFieldsRequired, ['contract_number','subcontract_number','other_number'], true)>
		<p>
		<div align="center"><hr><h3>Contract</h3></div>
		<div class="pl50">
			<div class="mb5">
				<div class="ib w s">Contract Number</div>
				<div class="ib"><input type="text" name="contract_number" id="contract_number" size=50
				<cfif contractType eq 'number'> value="<cfoutput>#contractNumber#</cfoutput>"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Subcontract Number</div>
				<div class="ib"><input type="text" name="subcontract_number" id="subcontract_number" size=50
				<cfif contractType eq 'subcontract_number'> value="<cfoutput>#contractNumber#</cfoutput>"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Other Number</div>
				<div class="ib"><input type="text" name="other_number" id="other_number" size=50
				<cfif contractType eq 'other_number'> value="<cfoutput>#contractNumber#</cfoutput>"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Contract Name</div>
				<div class="ib"><input type="text" name="contract_name" id="contract_number" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Task Order To</div>
				<div class="ib"><select name="task_order_to" id="task_order_to">
					<option></option>
				<cfoutput query="security_contracts">
					<option value="#security_contract_id#">#cn#</option>
				</cfoutput>
				</select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Primary Contractor</div>
				<div class="ib"><select name="company_id" id="company_id">
					<option></option>
				<cfoutput query="security_companies">
					<option value="#security_company_id#">#security_company_name#</option>
				</cfoutput>
				</select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Subcontractor(s)</div>
				<div class="ib"><select name="subcontractor" id="subcontractor" multiple size=5>
				<cfoutput query="security_companies">
					<option value="#security_company_id#">#security_company_name#</option>
				</cfoutput>
				</select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Contractor DB Contract Link</div>
				<div class="ib"><select name="cdb_contract_id" id="cdb_contract_id">
					<option></option>
				<cfoutput query="contractor_contracts">
					<option value="#contract_id#">#contract_number#</option>
				</cfoutput>
				</select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Organization</div>
				<div class="ib"><input name="organization" id="organization" size=25></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Contractor Cage Code</div>
				<div class="ib"><select name="contract_contractor_cage_code" id="contract_contractor_cage_code">
					<option></option>
				<cfoutput query="security_cage_codes">
					<option value="#security_cage_code_id#"<cfif contractorCageCode eq security_cage_code> selected</cfif>>#security_cage_code#</option>
				</cfoutput>
				</select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Subcontractor Cage Code</div>
				<div class="ib"><select name="contract_subcontractor_cage_code" id="contract_subcontractor_cage_code">
					<option></option>
				<cfoutput query="security_cage_codes">
					<option value="#security_cage_code_id#"<cfif subcontractorCageCode eq security_cage_code> selected</cfif>>#security_cage_code#</option>
				</cfoutput>
				</select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Performance Cage Code(s)</div>
				<div class="ib"><select name="contract_performance_cage_code" id="contract_performance_cage_code" multiple size=5>
				<cfoutput query="security_cage_codes">
					<option value="#security_cage_code_id#"<cfif performanceCageCode eq security_cage_code> selected</cfif>>#security_cage_code#</option>
				</cfoutput>
				</select></div>
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
            	<div class="ib w s" style="margin-top: 5px;">Flags:</div>
				<div class="ib">
					<label for="onbase" class="strong_label">On-base?</label><input type=checkbox name=onbase id=onbase class="strong_label">
					<label for="scg" class="strong_label">SCG?</label><input type=checkbox name=scg id=scg class="strong_label">
					<label for="ppp" class="strong_label">PPP?</label><input type=checkbox name=ppp id=ppp class="strong_label">
					<label for="ci" class="strong_label">CI?</label><input type=checkbox name=ci id=ci class="strong_label">
					<br>
					<label for="10e1" class="strong_label">10e(1)?</label><input type=checkbox name=10e1 id=10e1 class="strong_label">
					<label for="10e2" class="strong_label">10e(2)?</label><input type=checkbox name=10e2 id=10e2 class="strong_label">
					<label for="10f" class="strong_label">10f?</label><input type=checkbox name=10f id=10f class="strong_label">
				</div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Ignore This Contract?</div>
				<div class="ib"><input type=checkbox name=contract_ignore id=contract_ignore class="strong_label"></div>
			</div>
			</cfif>
			
			<cfif contractorCageCode eq '' and trim(len(formData['ctr_cage'])) gt 3>
				<cfset submit=1>
				<cfset junk = arrayAppend(fieldsRequired, ['contractor_cage_code', 'contractor_address1', 'contractor_city', 'contractor_state', 'contractor_zip_code'], "true")>

				<cfoutput>
			<div align="center"><hr><h3>Contractor Cage Code</h3></div>
			<div class="mb5">
				<div class="ib w s">Cage Code *</div>
				<div class="ib"><input type="text" name="contractor_cage_code" id="contractor_cage_code"<cfif structKeyExists(formData, 'ctr_cage')> value="#formData['ctr_cage']#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Company</div>
				<div class="ib"><select name="contractor_company_id" id="contractor_company_id">
            	<option></option>
            	<cfloop query="security_companies">
					<option value="#security_company_id#">#security_company_name#</option>
				</cfloop>
			</select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Location Name *</div>
				<div class="ib"><input type="text" name="contractor_company_name" id="contractor_company_name" size=50<cfif structKeyExists(contractorCageCodeAddress, 'name')> value="#contractorCageCodeAddress.name#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 1 *</div>
				<div class="ib"><input type="text" name="contractor_address1" id="contractor_address1" size=50<cfif structKeyExists(contractorCageCodeAddress, 'address')> value="#contractorCageCodeAddress.address#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 2</div>
				<div class="ib"><input type="text" name="contractor_address2" id="contractor_address2" size=50<cfif structKeyExists(contractorCageCodeAddress, 'suite')> value="#contractorCageCodeAddress.suite#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">City *</div>
				<div class="ib"><input type="text" name="contractor_city" id="contractor_city" size=50<cfif structKeyExists(contractorCageCodeAddress, 'city')> value="#contractorCageCodeAddress.city#"</cfif>></div>
			</div>
			<cfset myState=''>
			<cfif structKeyExists(contractorCageCodeAddress, 'state')><cfset myState=contractorCageCodeAddress.state></cfif>
			<cfset output=state_dropdown('contractor_state', myState)>
			<div class="mb5">
            	<div class="ib w s">State *</div>
				<div class="ib">#output#</div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Zip Code *</div>
				<div class="ib"><input type="text" name="contractor_zip_code" id="contractor_zip_code" size=11<cfif structKeyExists(contractorCageCodeAddress, 'zip')> value="#contractorCageCodeAddress.zip#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing Address 1</div>
				<div class="ib"><input type="text" name="contractor_classified_address1" id="contractor_classified_address1" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing Address 2</div>
				<div class="ib"><input type="text" name="contractor_classified_address2" id="contractor_classified_address2" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing City</div>
				<div class="ib"><input type="text" name="contractor_classified_city" id="contractor_classified_city" size=50></div>
			</div>
			<cfset output=state_dropdown('contractor_classified_state')>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing State</div>
				<div class="ib">#output#</div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing Zip Code</div>
				<div class="ib"><input type="text" name="contractor_classified_zip_code" id="contractor_classified_zip_code" size=11></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Phone</div>
				<div class="ib"><input name="contractor_phone" id="contractor_phone" size=25<cfif structKeyExists(contractorCageCodeAddress, 'phone')> value="#contractorCageCodeAddress.phone#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Email</div>
				<div class="ib"><input name="contractor_email" id="contractor_email" size=50<cfif structKeyExists(contractorCageCodeAddress, 'email')> value="#contractorCageCodeAddress.email#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Cognizant Security Office (CSO)</div>
				<div class="ib"><select name="contractor_cso_id" id="contractor_cso_id">
            	<option></option>
            	<cfloop query="security_cso">
            	<option value="#security_cso_id#"<cfif contractorCsoSymbol eq security_cso_symbol> selected</cfif>>#security_cso_symbol# #security_cso_location#, #security_cso_city#, #security_cso_state#</option>
            	</cfloop>
            </select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Ignore This Cage Code?</div>
				<div class="ib"><input type=checkbox name=ccc_ignore id=ccc_ignore class="strong_label"></div>
			</div>
				</cfoutput>
			</cfif>

			<cfif contractorCsoSymbol eq '' and trim(len(formData['ctr_ofc'])) gt 3>
				<cfset submit=1>
				<cfset junk = arrayAppend(fieldsRequired, ['contractor_cso_symbol', 'contractor_cso_location', 'contractor_cso_address1', 'contractor_cso_city', 'contractor_cso_state', 'contractor_cso_zip_code', 'contractor_cso_phone'], "true")>
			
				<cfoutput>
			<div align="center"><hr><h3>Contractor CSO</h3></div>
			<div class="mb5">
				<div class="ib w s">CSO Symbol *</div>
				<div class="ib"><input name="contractor_cso_symbol" id="contractor_cso_symbol" size=50<cfif structKeyExists(contractorCsoAddress, 'name')> value="#reReplace(contractorCsoAddress.name, ".+\((.*)\)", "\1", "ALL")#"</cfif>></div>
			</div>
			<div class="mb5">
				<div class="ib w s">CSO Location *</div>
				<div class="ib"><input name="contractor_cso_location" id="contractor_cso_location" size=50<cfif structKeyExists(contractorCsoAddress, 'name')> value="#reReplace(contractorCsoAddress.name, "(.+) \(.*\)", "\1", "ALL")#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 1 *</div>
				<div class="ib"><input name="contractor_cso_address1" id="contractor_cso_address1" size=50<cfif structKeyExists(contractorCsoAddress, 'address')> value="#contractorCsoAddress.address#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 2</div>
				<div class="ib"><input name="contractor_cso_address2" id="contractor_cso_address2" size=50<cfif structKeyExists(contractorCsoAddress, 'suite')> value="#contractorCsoAddress.suite#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">City *</div>
				<div class="ib"><input name="contractor_cso_city" id="contractor_cso_city" size=50<cfif structKeyExists(contractorCsoAddress, 'city')> value="#contractorCsoAddress.city#"</cfif>></div>
			</div>
			<cfset myState=''>
			<cfif structKeyExists(contractorCsoAddress, 'state')><cfset myState=contractorCsoAddress.state></cfif>
			<cfset output=state_dropdown('contractor_cso_state', myState)>
			<div class="mb5">
            	<div class="ib w s">State *</div>
				<div class="ib"><cfoutput>#output#</cfoutput></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Zip Code *</div>
				<div class="ib"><input name="contractor_cso_zip_code" id="contractor_cso_zip_code" size=11<cfif structKeyExists(contractorCsoAddress, 'zip')> value="#contractorCsoAddress.zip#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Phone *</div>
				<div class="ib"><input name="contractor_cso_phone" id="contractor_cso_phone" size=25<cfif structKeyExists(contractorCsoAddress, 'phone')> value="#contractorCsoAddress.phone#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Fax</div>
				<div class="ib"><input name="contractor_cso_fax" id="contractor_cso_fax" size=25<cfif structKeyExists(contractorCsoAddress, 'fax')> value="#contractorCsoAddress.fax#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Email</div>
				<div class="ib"><input name="contractor_cso_email" id="contractor_cso_email" size=50<cfif structKeyExists(contractorCsoAddress, 'email')> value="#contractorCsoAddress.email#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Contact</div>
				<div class="ib"><input name="contractor_cso_contact" id="contractor_cso_contact" size=50<cfif structKeyExists(contractorCsoAddress, 'foc')> value="#contractorCsoAddress.foc#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Ignore This CSO?</div>
				<div class="ib"><input type=checkbox name=ccso_ignore id=ccso_ignore class="strong_label"></div>
			</div>
				</cfoutput>
			</cfif>

			<cfif subcontractorCageCode eq '' and trim(len(formData['sub_cage'])) gt 3>
				<cfset submit=1>
				<cfset junk = arrayAppend(fieldsRequired, ['subcontractor_cage_code', 'subcontractor_address1', 'subcontractor_city', 'subcontractor_state', 'subcontractor_zip_code'], "true")>
				
				<cfoutput>
			<div align="center"><hr><h3>Subcontractor Cage Code</h3></div>
			<div class="mb5">
				<div class="ib w s">Cage Code *</div>
				<div class="ib"><input type="text" name="subcontractor_cage_code" id="subcontractor_cage_code"<cfif structKeyExists(formData, 'sub_cage')> value="#formData['sub_cage']#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Company</div>
				<div class="ib"><select name="subcontractor_company_id" id="subcontractor_company_id">
            	<option></option>
            	<cfloop query="security_companies">
					<option value="#security_company_id#">#security_company_name#</option>
				</cfloop>
			</select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Location Name *</div>
				<div class="ib"><input type="text" name="subcontractor_company_name" id="subcontractor_company_name" size=50<cfif structKeyExists(subcontractorCageCodeAddress, 'name')> value="#subcontractorCageCodeAddress.name#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 1 *</div>
				<div class="ib"><input type="text" name="subcontractor_address1" id="subcontractor_address1" size=50<cfif structKeyExists(subcontractorCageCodeAddress, 'address')> value="#subcontractorCageCodeAddress.address#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 2</div>
				<div class="ib"><input type="text" name="subcontractor_address2" id="subcontractor_address2" size=50<cfif structKeyExists(subcontractorCageCodeAddress, 'suite')> value="#subcontractorCageCodeAddress.suite#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">City *</div>
				<div class="ib"><input type="text" name="subcontractor_city" id="subcontractor_city" size=50<cfif structKeyExists(subcontractorCageCodeAddress, 'city')> value="#subcontractorCageCodeAddress.city#"</cfif>></div>
			</div>
			<cfset myState=''>
			<cfif structKeyExists(subcontractorCageCodeAddress, 'state')><cfset myState=subcontractorCageCodeAddress.state></cfif>
			<cfset output=state_dropdown('subcontractor_state', myState)>
			<div class="mb5">
            	<div class="ib w s">State *</div>
				<div class="ib">#output#</div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Zip Code *</div>
				<div class="ib"><input type="text" name="subcontractor_zip_code" id="subcontractor_zip_code" size=11<cfif structKeyExists(subcontractorCageCodeAddress, 'zip')> value="#subcontractorCageCodeAddress.zip#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing Address 1</div>
				<div class="ib"><input type="text" name="subcontractor_classified_address1" id="subcontractor_classified_address1" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing Address 2</div>
				<div class="ib"><input type="text" name="subcontractor_classified_address2" id="subcontractor_classified_address2" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing City</div>
				<div class="ib"><input type="text" name="subcontractor_classified_city" id="subcontractor_classified_city" size=50></div>
			</div>
			<cfset output=state_dropdown('subcontractor_classified_state')>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing State</div>
				<div class="ib">#output#</div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing Zip Code</div>
				<div class="ib"><input type="text" name="subcontractor_classified_zip_code" id="subcontractor_classified_zip_code" size=11></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Phone</div>
				<div class="ib"><input name="subcontractor_phone" id="subcontractor_phone" size=25<cfif structKeyExists(subcontractorCageCodeAddress, 'phone')> value="#subcontractorCageCodeAddress.phone#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Email</div>
				<div class="ib"><input name="subcontractor_email" id="subcontractor_email" size=50<cfif structKeyExists(subcontractorCageCodeAddress, 'email')> value="#subcontractorCageCodeAddress.email#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Cognizant Security Office (CSO)</div>
				<div class="ib"><select name="subcontractor_cso_id" id="subcontractor_cso_id">
            	<option></option>
            	<cfloop query="security_cso">
            	<option value="#security_cso_id#"<cfif subcontractorCsoSymbol eq security_cso_symbol> selected</cfif>>#security_cso_symbol# #security_cso_location#, #security_cso_city#, #security_cso_state#</option>
            	</cfloop>
            </select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Ignore This Cage Code?</div>
				<div class="ib"><input type=checkbox name=scc_ignore id=scc_ignore class="strong_label"></div>
			</div>
				</cfoutput>
			</cfif>
			
			<cfif subcontractorCsoSymbol eq '' and trim(len(formData['sub_ofc'])) gt 3>
				<cfset submit=1>
				<cfset junk = arrayAppend(fieldsRequired, ['subcontractor_cso_symbol', 'subcontractor_cso_location', 'subcontractor_cso_address1', 'subcontractor_cso_city', 'subcontractor_cso_state', 'subcontractor_cso_zip_code', 'subcontractor_cso_phone'], "true")>
				
				<cfoutput>
			<div align="center"><hr><h3>Subcontractor CSO</h3></div>
			<div class="mb5">
				<div class="ib w s">CSO Symbol *</div>
				<div class="ib"><input name="subcontractor_cso_symbol" id="subcontractor_cso_symbol" size=50<cfif structKeyExists(subcontractorCsoAddress, 'name')> value="#reReplace(subcontractorCsoAddress.name, ".+\((.*)\)", "\1", "ALL")#"</cfif>></div>
			</div>
			<div class="mb5">
				<div class="ib w s">CSO Location *</div>
				<div class="ib"><input name="subcontractor_cso_location" id="subcontractor_cso_location" size=50<cfif structKeyExists(subcontractorCsoAddress, 'name')> value="#reReplace(subcontractorCsoAddress.name, "(.+) \(.*\)", "\1", "ALL")#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 1 *</div>
				<div class="ib"><input name="subcontractor_cso_address1" id="subcontractor_cso_address1" size=50<cfif structKeyExists(subcontractorCsoAddress, 'address')> value="#subcontractorCsoAddress.address#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 2</div>
				<div class="ib"><input name="subcontractor_cso_address2" id="subcontractor_cso_address2" size=50<cfif structKeyExists(subcontractorCsoAddress, 'suite')> value="#subcontractorCsoAddress.suite#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">City *</div>
				<div class="ib"><input name="subcontractor_cso_city" id="subcontractor_cso_city" size=50<cfif structKeyExists(subcontractorCsoAddress, 'city')> value="#subcontractorCsoAddress.city#"</cfif>></div>
			</div>
			<cfset myState=''>
			<cfif structKeyExists(subcontractorCsoAddress, 'state')><cfset myState=subcontractorCsoAddress.state></cfif>
			<cfset output=state_dropdown('subcontractor_cso_state', myState)>
			<div class="mb5">
            	<div class="ib w s">State *</div>
				<div class="ib">#output#</div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Zip Code *</div>
				<div class="ib"><input name="subcontractor_cso_zip_code" id="subcontractor_cso_zip_code" size=11<cfif structKeyExists(subcontractorCsoAddress, 'zip')> value="#subcontractorCsoAddress.zip#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Phone *</div>
				<div class="ib"><input name="subcontractor_cso_phone" id="subcontractor_cso_phone" size=25<cfif structKeyExists(subcontractorCsoAddress, 'phone')> value="#subcontractorCsoAddress.phone#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Fax</div>
				<div class="ib"><input name="subcontractor_cso_fax" id="subcontractor_cso_fax" size=25<cfif structKeyExists(subcontractorCsoAddress, 'fax')> value="#subcontractorCsoAddress.fax#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Email</div>
				<div class="ib"><input name="subcontractor_cso_email" id="subcontractor_cso_email" size=50<cfif structKeyExists(subcontractorCsoAddress, 'email')> value="#subcontractorCsoAddress.email#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Contact</div>
				<div class="ib"><input name="subcontractor_cso_contact" id="subcontractor_cso_contact" size=50<cfif structKeyExists(subcontractorCsoAddress, 'foc')> value="#subcontractorCsoAddress.foc#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Ignore This CSO?</div>
				<div class="ib"><input type=checkbox name=scso_ignore id=scso_ignore class="strong_label"></div>
			</div>
				</cfoutput>
			</cfif>

			<cfif performanceCageCode eq '' and trim(len(formData['perf_cage'])) gt 3>
				<cfset submit=1>
				<cfset junk = arrayAppend(fieldsRequired, ['performance_cage_code', 'performance_address1', 'performance_city', 'performance_state', 'performance_zip_code'], "true")>
				
				<cfoutput>
			<div align="center"><hr><h3>Performance Cage Code</h3></div>
			<div class="mb5">
				<div class="ib w s">Cage Code *</div>
				<div class="ib"><input type="text" name="performance_cage_code" id="performance_cage_code"<cfif structKeyExists(formData, 'perf_cage')> value="#formData['perf_cage']#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Company</div>
				<div class="ib"><select name="performance_company_id" id="performance_company_id">
            	<option></option>
            	<cfloop query="security_companies">
					<option value="#security_company_id#">#security_company_name#</option>
				</cfloop>
			</select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Location Name *</div>
				<div class="ib"><input type="text" name="performance_company_name" id="performance_company_name" size=50<cfif structKeyExists(performanceCageCodeAddress, 'name')> value="#performanceCageCodeAddress.name#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 1 *</div>
				<div class="ib"><input type="text" name="performance_address1" id="performance_address1" size=50<cfif structKeyExists(performanceCageCodeAddress, 'address')> value="#performanceCageCodeAddress.address#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 2</div>
				<div class="ib"><input type="text" name="performance_address2" id="performance_address2" size=50<cfif structKeyExists(performanceCageCodeAddress, 'suite')> value="#performanceCageCodeAddress.suite#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">City *</div>
				<div class="ib"><input type="text" name="performance_city" id="performance_city" size=50<cfif structKeyExists(performanceCageCodeAddress, 'city')> value="#performanceCageCodeAddress.city#"</cfif>></div>
			</div>
			<cfset myState=''>
			<cfif structKeyExists(performanceCageCodeAddress, 'state')><cfset myState=performanceCageCodeAddress.state></cfif>
			<cfset output=state_dropdown('performance_state', myState)>
			<div class="mb5">
            	<div class="ib w s">State *</div>
				<div class="ib">#output#</div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Zip Code *</div>
				<div class="ib"><input type="text" name="performance_zip_code" id="performance_zip_code" size=11<cfif structKeyExists(performanceCageCodeAddress, 'zip')> value="#performanceCageCodeAddress.zip#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing Address 1</div>
				<div class="ib"><input type="text" name="performance_classified_address1" id="performance_classified_address1" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing Address 2</div>
				<div class="ib"><input type="text" name="performance_classified_address2" id="performance_classified_address2" size=50></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing City</div>
				<div class="ib"><input type="text" name="performance_classified_city" id="performance_classified_city" size=50></div>
			</div>
			<cfset output=state_dropdown('performance_classified_state')>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing State</div>
				<div class="ib">#output#</div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Classified Mailing Zip Code</div>
				<div class="ib"><input type="text" name="performance_classified_zip_code" id="performance_classified_zip_code" size=11></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Phone</div>
				<div class="ib"><input name="performance_phone" id="performance_phone" size=25<cfif structKeyExists(performanceCageCodeAddress, 'phone')> value="#performanceCageCodeAddress.phone#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Email</div>
				<div class="ib"><input name="performance_email" id="performance_email" size=50<cfif structKeyExists(performanceCageCodeAddress, 'email')> value="#performanceCageCodeAddress.email#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Cognizant Security Office (CSO)</div>
				<div class="ib"><select name="performance_cso_id" id="performance_cso_id">
            	<option></option>
            	<cfloop query="security_cso">
            	<option value="#security_cso_id#"<cfif performanceCsoSymbol eq security_cso_symbol> selected</cfif>>#security_cso_symbol# #security_cso_location#, #security_cso_city#, #security_cso_state#</option>
            	</cfloop>
            </select></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Ignore This CSO?</div>
				<div class="ib"><input type=checkbox name=pcc_ignore id=pcc_ignore class="strong_label"></div>
			</div>
				</cfoutput>
			</cfif>
			
			<cfif performanceCsoSymbol eq '' and trim(len(formData['perf_ofc'])) gt 15>
				<cfset submit=1>
				<cfset junk = arrayAppend(fieldsRequired, ['performance_cso_symbol', 'performance_cso_location', 'performance_cso_address1', 'performance_cso_city', 'performance_cso_state', 'performance_cso_zip_code', 'performance_cso_phone'], "true")>
				
				<cfoutput>
			<div align="center"><hr><h3>Performance CSO</h3></div>
			<div class="mb5">
				<div class="ib w s">CSO Symbol *</div>
				<div class="ib"><input name="performance_cso_symbol" id="performance_cso_symbol" size=50<cfif structKeyExists(performanceCsoAddress, 'name')> value="#reReplace(performanceCsoAddress.name, ".+\((.*)\)", "\1", "ALL")#"</cfif>></div>
			</div>
			<div class="mb5">
				<div class="ib w s">CSO Location *</div>
				<div class="ib"><input name="performance_cso_location" id="performance_cso_location" size=50<cfif structKeyExists(performanceCsoAddress, 'name')> value="#reReplace(performanceCsoAddress.name, "(.+) \(.*\)", "\1", "ALL")#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 1 *</div>
				<div class="ib"><input name="performance_cso_address1" id="performance_cso_address1" size=50<cfif structKeyExists(performanceCsoAddress, 'address')> value="#performanceCsoAddress.address#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Address Line 2</div>
				<div class="ib"><input name="performance_cso_address2" id="performance_cso_address2" size=50<cfif structKeyExists(performanceCsoAddress, 'suite')> value="#performanceCsoAddress.suite#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">City *</div>
				<div class="ib"><input name="performance_cso_city" id="performance_cso_city" size=50<cfif structKeyExists(performanceCsoAddress, 'city')> value="#performanceCsoAddress.city#"</cfif>></div>
			</div>
			<cfset myState=''>
			<cfif structKeyExists(performanceCsoAddress, 'state')><cfset myState=performanceCsoAddress.state></cfif>
			<cfset output=state_dropdown('performance_cso_state', myState)>
			<div class="mb5">
            	<div class="ib w s">State *</div>
				<div class="ib">#output#</div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Zip Code *</div>
				<div class="ib"><input name="performance_cso_zip_code" id="performance_cso_zip_code" size=11<cfif structKeyExists(performanceCsoAddress, 'zip')> value="#performanceCsoAddress.zip#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Phone *</div>
				<div class="ib"><input name="performance_cso_phone" id="performance_cso_phone" size=25<cfif structKeyExists(performanceCsoAddress, 'phone')> value="#performanceCsoAddress.phone#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Fax</div>
				<div class="ib"><input name="performance_cso_fax" id="performance_cso_fax" size=25<cfif structKeyExists(performanceCsoAddress, 'fax')> value="#performanceCsoAddress.fax#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Email</div>
				<div class="ib"><input name="performance_cso_email" id="performance_cso_email" size=50<cfif structKeyExists(performanceCsoAddress, 'email')> value="#performanceCsoAddress.email#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Contact</div>
				<div class="ib"><input name="performance_cso_contact" id="performance_cso_contact" size=50<cfif structKeyExists(performanceCsoAddress, 'foc')> value="#performanceCsoAddress.foc#"</cfif>></div>
			</div>
			<div class="mb5">
            	<div class="ib w s">Ignore This CSO?</div>
				<div class="ib"><input type=checkbox name=pcso_ignore id=pcso_ignore class="strong_label"></div>
			</div>
				</cfoutput>
			</cfif>

			<cfif len(contractNumber) gt 0>
				<cfset submit=1>
			<div align="center"><hr class="mt10"><h3>Project Name</h3></div>
			<div class="mb5">
				<div class="ib w s">Project Name</div>
				<div class="ib"><select name="project_name" id="project_name" multi size=5>
				<cfoutput query="security_project_names">
					<option value="#security_project_id#">#security_project_name#</option>
				</cfoutput>
				</select></div>
			</div>
			</cfif>
			
			<hr>
			<div class="mt10">
			<cfif submit>
				<!--- Make sure required fields are filled in before submitting. Spit out javascript code to allow checking them --->
				<cfoutput>
			<script type="text/javascript">
				var fieldsRequired = [#listQualify(arrayToList(fieldsRequired), "'")#];
				var someOfFieldsRequired = [#listQualify(arrayToList(someOfFieldsRequired), "'")#];
				
				function getFieldsRequired() {return fieldsRequired;}
				function getSomeOfFieldsRequired() {return someOfFieldsRequired;}
			</script>
				</cfoutput>
			<input type="submit" value="Submit">
			</cfif>
			</div>
		</div>
		</form>
	
		<cfcatch type = "any">
			<!--- The message to display. --->
			<h3>Oops!</h3>
			<cfoutput>
				<!--- The diagnostic message from ColdFusion. --->
				<p>Caught an exception, type = #CFCATCH.TYPE#</p> 
				<p>#cfcatch.message#</p>
				<cfif len(cfcatch.detail) gt 0>
				<p>The details are:</p>
				#cfcatch.detail#
				</cfif>
			</cfoutput>
			<cfif structKeyExists(form, 'jsfile1') and fileExists("#tempDir#/#myfilename#")>
				<cffile action="delete" file="#tempDir#/#myfilename#">
			</cfif>
			<!---<cfdirectory action="list" directory="#tempDir#" name="contents">
			<cfdump var="#contents#" label="Result">--->
		</cfcatch>
	</cftry>
	</div>
</div>
<cfinclude template="footer.html">
</body>
</html>