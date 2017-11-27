<cfif not variables.permission_type IS "Edit">
	<cfinclude template="unauthorized_page.cfm">
    <cfabort>
</cfif>

<html>
<head>
<title>Process a DD254</title>
<cfinclude template="meta.html">
<script src="validateFields.js"></script>
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
	<cfset message=''>
	<cfset error=''>
	<cfoutput>
	
	<cftry>
		<cfinclude template="db.cfm">
		<cfif structKeyExists(form, 'performance_cso_symbol') and not structKeyExists(form, 'pcso_ignore')>
			<cfquery name="security_csos" datasource="#contractordb#">
				select security_cso_id, security_cso_location
				from security_cognizant_security_office
				where security_cso_symbol='#form.performance_cso_symbol#'
			</cfquery>
			<cfset message = message & '<br>' & "Processing performance_cso_symbol: #form.performance_cso_symbol#">
			<cfif #security_csos.RecordCount# eq 0>
				<cfset fields = ''>
				<cfset values = ''>
				<cfset data = getCsoStruct()>
				
				<cfif structKeyExists(form, 'performance_cso_symbol')><cfset data.cso_symbol = form.performance_cso_symbol></cfif>
				<cfif structKeyExists(form, 'performance_cso_location')><cfset data.cso_location = form.performance_cso_location></cfif>
				<cfif structKeyExists(form, 'performance_cso_address1')><cfset data.cso_address1 = form.performance_cso_address1></cfif>
				<cfif structKeyExists(form, 'performance_cso_address2')><cfset data.cso_address2 = form.performance_cso_address2></cfif>
				<cfif structKeyExists(form, 'performance_cso_city')><cfset data.cso_city = form.performance_cso_city></cfif>
				<cfif structKeyExists(form, 'performance_cso_state')><cfset data.cso_state = form.performance_cso_state></cfif>
				<cfif structKeyExists(form, 'performance_cso_zip_code')><cfset data.cso_zip_code = form.performance_cso_zip_code></cfif>
				<cfif structKeyExists(form, 'performance_cso_phone')><cfset data.cso_phone = form.performance_cso_phone></cfif>
				<cfif structKeyExists(form, 'performance_cso_email')><cfset data.cso_email = form.performance_cso_email></cfif>
				<cfif structKeyExists(form, 'performance_cso_fax')><cfset data.cso_fax = form.performance_cso_fax></cfif>
				<cfif structKeyExists(form, 'performance_cso_foc')><cfset data.cso_contact = form.performance_cso_foc></cfif>
				
				<cfset return = insertCso(data)>
				<cfif return.status>
					<cfset my_performance_cso_id = return.cso_id>
					<cfset message = message & '<br>' & return.message>
				<cfelse>
					<cfset error = error & '<br>' & return.message>
				</cfif>
			<cfelse>
				<cfset message = message & ' (already in the database)'>
				<cfset my_performance_cso_id = security_csos.security_cso_id>
			</cfif>
		</cfif>
	
		<cfif structKeyExists(form, 'performance_cage_code') and not structKeyExists(form, 'pcc_ignore')>
			<cfquery name="security_cage_codes" datasource="#contractordb#">
				select security_cso_location
				from security_cage_code
				where security_cage_code='#form.performance_cage_code#'
			</cfquery>
			<cfset message = message & '<br>' & "Processing performance_cage_code: #form.performance_cage_code#">
			<cfif #security_cage_codes.RecordCount# eq 0>
				<cfset fields = ''>
				<cfset values = ''>
				<cfset data = getCageCodeStruct()>
				
				<cfif structKeyExists(form, 'performance_cage_code')><cfset data.cage_code = form.performance_cage_code></cfif>
				<cfif structKeyExists(form, 'performance_company_id')><cfset data.company_id = form.performance_company_id></cfif>
				<cfif structKeyExists(form, 'performance_company_name')><cfset data.company_name = form.performance_company_name></cfif>
				<cfif structKeyExists(form, 'performance_address1')><cfset data.address1 = form.performance_address1></cfif>
				<cfif structKeyExists(form, 'performance_address2')><cfset data.address2 = form.performance_address2></cfif>
				<cfif structKeyExists(form, 'performance_city')><cfset data.city = form.performance_city></cfif>
				<cfif structKeyExists(form, 'performance_state')><cfset data.state = form.performance_state></cfif>
				<cfif structKeyExists(form, 'performance_zip_code')><cfset data.zip_code = form.performance_zip_code></cfif>
				<cfif structKeyExists(form, 'performance_classified_address1')><cfset data.classified_address1 = form.performance_classified_address1></cfif>
				<cfif structKeyExists(form, 'performance_classified_address2')><cfset data.classified_address2 = form.performance_classified_address2></cfif>
				<cfif structKeyExists(form, 'performance_classified_city')><cfset data.classified_city = form.performance_classified_city></cfif>
				<cfif structKeyExists(form, 'performance_classified_state')><cfset data.classified_state = form.performance_classified_state></cfif>
				<cfif structKeyExists(form, 'performance_classified_zip_code')><cfset data.classified_zip_code = form.performance_classified_zip_code></cfif>
				<cfif structKeyExists(form, 'performance_phone')><cfset data.phone = form.performance_phone></cfif>
				<cfif structKeyExists(form, 'performance_email')><cfset data.email = form.performance_email></cfif>
				<cfif structKeyExists(form, 'performance_cso_id')><cfset data.cso_id = form.performance_cso_id></cfif>
				
				<cfset return = insertCageCode(data)>
				<cfif return.status>
					<cfset my_performance_cage_code_id = return.cage_code_id>
					<cfset message = message & '<br>' & return.message>
				<cfelse>
					<cfset error = error & '<br>' & return.message>
				</cfif>
			<cfelse>
				<cfset message = message & ' (already in the database)'>
				<cfset my_performance_cage_code_id = security_cage_codes.security_cage_code_id>
			</cfif>
		</cfif>
	
		<cfif structKeyExists(form, 'subcontractor_cso_symbol') and not structKeyExists(form, 'scso_ignore')>
			<cfquery name="security_csos" datasource="#contractordb#">
				select security_cso_id, security_cso_location
				from security_cognizant_security_office
				where security_cso_symbol='#form.subcontractor_cso_symbol#'
			</cfquery>
			<cfset message = message & '<br>' & "Processing subcontractor_cso_symbol: #form.subcontractor_cso_symbol#">
			<cfif #security_csos.RecordCount# eq 0>
				<cfset fields = ''>
				<cfset values = ''>
				<cfset data = getCsoStruct()>
				
				<cfif structKeyExists(form, 'subcontractor_cso_symbol')><cfset data.cso_symbol = form.subcontractor_cso_symbol></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_location')><cfset data.cso_location = form.subcontractor_cso_location></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_address1')><cfset data.cso_address1 = form.subcontractor_cso_address1></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_address2')><cfset data.cso_address2 = form.subcontractor_cso_address2></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_city')><cfset data.cso_city = form.subcontractor_cso_city></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_state')><cfset data.cso_state = form.subcontractor_cso_state></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_zip_code')><cfset data.cso_zip_code = form.subcontractor_cso_zip_code></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_phone')><cfset data.cso_phone = form.subcontractor_cso_phone></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_email')><cfset data.cso_email = form.subcontractor_cso_email></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_fax')><cfset data.cso_fax = form.subcontractor_cso_fax></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_foc')><cfset data.cso_contact = form.subcontractor_cso_foc></cfif>
				
				<cfset return = insertCso(data)>
				<cfif return.status>
					<cfset my_subcontractor_cso_id = return.cso_id>
					<cfset message = message & '<br>' & return.message>
				<cfelse>
					<cfset error = error & '<br>' & return.message>
				</cfif>
			<cfelse>
				<cfset message = message & ' (already in the database)'>
				<cfset my_subcontractor_cso_id = security_csos.security_cso_id>
			</cfif>
		</cfif>
	
		<cfif structKeyExists(form, 'subcontractor_cage_code') and not structKeyExists(form, 'scc_ignore')>
			<cfquery name="security_cage_codes" datasource="#contractordb#">
				select security_cage_code_id
				from security_cage_code
				where security_cage_code='#form.subcontractor_cage_code#'
			</cfquery>
			<cfset message = message & '<br>' & "Processing subcontractor_cage_code: #form.subcontractor_cage_code#">
			<cfif #security_cage_codes.RecordCount# eq 0>
				<cfset fields = ''>
				<cfset values = ''>
				<cfset data = getCageCodeStruct()>
				
				<cfif structKeyExists(form, 'subcontractor_cage_code')><cfset data.cage_code = form.subcontractor_cage_code></cfif>
				<cfif structKeyExists(form, 'subcontractor_company_id')><cfset data.company_id = form.subcontractor_company_id></cfif>
				<cfif structKeyExists(form, 'subcontractor_company_name')><cfset data.company_name = form.subcontractor_company_name></cfif>
				<cfif structKeyExists(form, 'subcontractor_address1')><cfset data.address1 = form.subcontractor_address1></cfif>
				<cfif structKeyExists(form, 'subcontractor_address2')><cfset data.address2 = form.subcontractor_address2></cfif>
				<cfif structKeyExists(form, 'subcontractor_city')><cfset data.city = form.subcontractor_city></cfif>
				<cfif structKeyExists(form, 'subcontractor_state')><cfset data.state = form.subcontractor_state></cfif>
				<cfif structKeyExists(form, 'subcontractor_zip_code')><cfset data.zip_code = form.subcontractor_zip_code></cfif>
				<cfif structKeyExists(form, 'subcontractor_classified_address1')><cfset data.classified_address1 = form.subcontractor_classified_address1></cfif>
				<cfif structKeyExists(form, 'subcontractor_classified_address2')><cfset data.classified_address2 = form.subcontractor_classified_address2></cfif>
				<cfif structKeyExists(form, 'subcontractor_classified_city')><cfset data.classified_city = form.subcontractor_classified_city></cfif>
				<cfif structKeyExists(form, 'subcontractor_classified_state')><cfset data.classified_state = form.subcontractor_classified_state></cfif>
				<cfif structKeyExists(form, 'subcontractor_classified_zip_code')><cfset data.classified_zip_code = form.subcontractor_classified_zip_code></cfif>
				<cfif structKeyExists(form, 'subcontractor_phone')><cfset data.phone = form.subcontractor_phone></cfif>
				<cfif structKeyExists(form, 'subcontractor_email')><cfset data.email = form.subcontractor_email></cfif>
				<cfif structKeyExists(form, 'subcontractor_cso_id')><cfset data.cso_id = form.subcontractor_cso_id></cfif>
				
				<cfset return = insertCageCode(data)>
				<cfif return.status>
					<cfset my_subcontractor_cage_code_id = return.cage_code_id>
					<cfset message = message & '<br>' & return.message>
				<cfelse>
					<cfset error = error & '<br>' & return.message>
				</cfif>
			<cfelse>
				<cfset message = message & ' (already in the database)'>
				<cfset my_subcontractor_cage_code_id = security_cage_codes.security_cage_code_id>
			</cfif>
		</cfif>
	
		<cfif structKeyExists(form, 'contractor_cso_symbol') and not structKeyExists(form, 'ccso_ignore')>
			<cfquery name="security_csos" datasource="#contractordb#">
				select security_cso_id, security_cso_location
				from security_cognizant_security_office
				where security_cso_symbol='#form.contractor_cso_symbol#'
			</cfquery>
			<cfset message = message & '<br>' & "Processing contractor_cso_symbol: #form.contractor_cso_symbol#">
			<cfif #security_csos.RecordCount# eq 0>
				<cfset fields = ''>
				<cfset values = ''>
				<cfset data = getCsoStruct()>
				
				<cfif structKeyExists(form, 'contractor_cso_symbol')><cfset data.cso_symbol = form.contractor_cso_symbol></cfif>
				<cfif structKeyExists(form, 'contractor_cso_location')><cfset data.cso_location = form.contractor_cso_location></cfif>
				<cfif structKeyExists(form, 'contractor_cso_address1')><cfset data.cso_address1 = form.contractor_cso_address1></cfif>
				<cfif structKeyExists(form, 'contractor_cso_address2')><cfset data.cso_address2 = form.contractor_cso_address2></cfif>
				<cfif structKeyExists(form, 'contractor_cso_city')><cfset data.cso_city = form.contractor_cso_city></cfif>
				<cfif structKeyExists(form, 'contractor_cso_state')><cfset data.cso_state = form.contractor_cso_state></cfif>
				<cfif structKeyExists(form, 'contractor_cso_zip_code')><cfset data.cso_zip_code = form.contractor_cso_zip_code></cfif>
				<cfif structKeyExists(form, 'contractor_cso_phone')><cfset data.cso_phone = form.contractor_cso_phone></cfif>
				<cfif structKeyExists(form, 'contractor_cso_email')><cfset data.cso_email = form.contractor_cso_email></cfif>
				<cfif structKeyExists(form, 'contractor_cso_fax')><cfset data.cso_fax = form.contractor_cso_fax></cfif>
				<cfif structKeyExists(form, 'contractor_cso_foc')><cfset data.cso_contact = form.contractor_cso_foc></cfif>
				
				<cfset return = insertCso(data)>
				<cfif return.status>
					<cfset my_contractor_cso_id = return.cso_id>
					<cfset message = message & '<br>' & return.message>
				<cfelse>
					<cfset error = error & '<br>' & return.message>
				</cfif>
			<cfelse>
				<cfset message = message & ' (already in the database)'>
				<cfset my_contractor_cso_id = security_csos.security_cso_id>
			</cfif>
		</cfif>
	
		<cfif structKeyExists(form, 'contractor_cage_code') and not structKeyExists(form, 'ccc_ignore')>
			<cfquery name="security_cage_codes" datasource="#contractordb#">
				select security_cage_code_id
				from security_cage_code
				where security_cage_code='#form.contractor_cage_code#'
			</cfquery>
			<cfset message = message & '<br>' & "Processing contractor_cage_code: #form.contractor_cage_code#">
			<cfif #security_cage_codes.RecordCount# eq 0>
				<cfset fields = ''>
				<cfset values = ''>
				<cfset cdata = getCageCodeStruct()>
				
				<cfif structKeyExists(form, 'contractor_cage_code')><cfset cdata.cage_code = form.contractor_cage_code></cfif>
				<cfif structKeyExists(form, 'contractor_company_id')><cfset cdata.company_id = form.contractor_company_id></cfif>
				<cfif structKeyExists(form, 'contractor_company_name')><cfset cdata.company_name = form.contractor_company_name></cfif>
				<cfif structKeyExists(form, 'contractor_address1')><cfset cdata.address1 = form.contractor_address1></cfif>
				<cfif structKeyExists(form, 'contractor_address2')><cfset cdata.address2 = form.contractor_address2></cfif>
				<cfif structKeyExists(form, 'contractor_city')><cfset cdata.city = form.contractor_city></cfif>
				<cfif structKeyExists(form, 'contractor_state')><cfset cdata.state = form.contractor_state></cfif>
				<cfif structKeyExists(form, 'contractor_zip_code')><cfset cdata.zip_code = form.contractor_zip_code></cfif>
				<cfif structKeyExists(form, 'contractor_classified_address1')><cfset cdata.classified_address1 = form.contractor_classified_address1></cfif>
				<cfif structKeyExists(form, 'contractor_classified_address2')><cfset cdata.classified_address2 = form.contractor_classified_address2></cfif>
				<cfif structKeyExists(form, 'contractor_classified_city')><cfset cdata.classified_city = form.contractor_classified_city></cfif>
				<cfif structKeyExists(form, 'contractor_classified_state')><cfset cdata.classified_state = form.contractor_classified_state></cfif>
				<cfif structKeyExists(form, 'contractor_classified_zip_code')><cfset cdata.classified_zip_code = form.contractor_classified_zip_code></cfif>
				<cfif structKeyExists(form, 'contractor_phone')><cfset cdata.phone = form.contractor_phone></cfif>
				<cfif structKeyExists(form, 'contractor_email')><cfset cdata.email = form.contractor_email></cfif>
				<cfif structKeyExists(form, 'contractor_cso_id')><cfset cdata.cso_id = form.contractor_cso_id></cfif>
				
				<cfset return = insertCageCode(data)>
				<cfif return.status>
					<cfset my_contractor_cage_code_id = return.cage_code_id>
					<cfset message = message & '<br>' & return.message>
				<cfelse>
					<cfset error = error & '<br>' & return.message>
				</cfif>
			<cfelse>
				<cfset message = message & ' (already in the database)'>
				<cfset my_contractor_cage_code_id = security_cage_codes.security_cage_code_id>
			</cfif>
		</cfif>
	
		<cfif structKeyExists(form, 'contract_status') and not structKeyExists(form, 'contract_ignore')>
			<cfquery name="security_contracts" datasource="#contractordb#">
				select security_contract_id
				from security_contract
				where 
				<cfif structKeyExists(form, "contract_number") and #form.contract_number# neq ''>
					security_contract_number='#form.contract_number#'
				<cfelseif structKeyExists(form, "subcontract_number") and #form.subcontract_number# neq ''>
					security_contract_subcontract_number='#form.subcontract_number#'
				<cfelseif structKeyExists(form, "other_number") and #form.other_number# neq ''>
					security_contract_other_number='#form.other_number#'
				</cfif>
			</cfquery>
			<cfset message = message & '<br>' & "Processing contract_number: #form.contract_number#">
			<cfif #security_contracts.RecordCount# eq 0>
				<cfset fields = ''>
				<cfset values = ''>
				<cfset data = getContractStruct()>
				
				<cfif structKeyExists(data,"onbase")><cfset my_onbase=1></cfif>
				<cfif structKeyExists(form, 'contract_number')><cfset data.contract_number = form.contract_number></cfif>
				<cfif structKeyExists(form, 'subcontract_number')><cfset data.subcontract_number = form.subcontract_number></cfif>
				<cfif structKeyExists(form, 'other_number')><cfset data.other_number = form.other_number></cfif>
				<cfif structKeyExists(form, 'contract_name')><cfset data.contract_name = form.contract_name></cfif>
				<cfif structKeyExists(form, 'contract_status')><cfset data.contract_status = form.contract_status></cfif>
				<cfif structKeyExists(form, 'contract_contractor_cage_code') and len(form.contract_contractor_cage_code) gt 0><cfset data.contractor_cage_code = form.contract_contractor_cage_code>
				<cfelseif isDefined("my_contractor_cage_code_id")><cfset data.contractor_cage_code = my_contractor_cage_code_id></cfif>
				<cfif structKeyExists(form, 'contract_subcontractor_cage_code') and len(form.contract_subcontractor_cage_code) gt 0><cfset data.subcontractor_cage_code = form.contract_subcontractor_cage_code>
				<cfelseif isDefined("my_subcontractor_cage_code_id")><cfset data.subcontractor_cage_code = my_subcontractor_cage_code_id></cfif>
				<cfif structKeyExists(form, 'contract_performance_cage_code') and len(form.contract_performance_cage_code) gt 0><cfset data.performance_cage_code = form.contract_performance_cage_code>
				<cfelseif isDefined("my_performance_cage_code_id")><cfset data.performance_cage_code = my_performance_cage_code_id></cfif>
				<cfif structKeyExists(form, 'company_id')><cfset data.company_id = form.company_id></cfif>
				<cfif structKeyExists(form, 'subcontractor')><cfset data.subcontractor = form.subcontractor></cfif>
				<cfif structKeyExists(form, 'cdb_contract_id')><cfset data.cdb_contract_id = form.cdb_contract_id></cfif>
				<cfif structKeyExists(form, 'onbase') and len(form.onbase) gt 0><cfset data.onbase = form.onbase></cfif>
				<cfif structKeyExists(form, 'scg') and len(form.scg) gt 0><cfset data.scg = form.scg></cfif>
				<cfif structKeyExists(form, 'ppp') and len(form.ppp) gt 0><cfset data.ppp = form.ppp></cfif>
				<cfif structKeyExists(form, 'ci') and len(form.ci) gt 0><cfset data.ci = form.ci></cfif>
				<cfif structKeyExists(form, '10e1') and len(form.10e1) gt 0><cfset data.10e1 = form.10e1></cfif>
				<cfif structKeyExists(form, '10e2') and len(form.10e2) gt 0><cfset data.10e2 = form.10e2></cfif>
				<cfif structKeyExists(form, '10f') and len(form.10f) gt 0><cfset data.10f = form.10f></cfif>
				<cfif structKeyExists(form, 'task_order_to')><cfset data.task_order_to = form.task_order_to></cfif>
				 
				<cfset return = insertContract(data)>
				<cfif return.status>
					<cfset my_contract_id = return.contract_id>
					<cfset message = message & '<br>' & return.message>
				<cfelse>
					<cfset error = error & '<br>' & return.message>
				</cfif>

				<cfif structKeyExists(form, 'project_name') and #form.project_name# neq ''>
					<cfquery datasource="#contractordb#">
						insert into security_project_to_contract (security_project_id, security_contract_id)
						values (
							<cfqueryparam value="#form.project_name#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#my_contract_id#" cfsqltype="cf_sql_integer">
						)
					</cfquery>
					<cfset message = message & '<br>' & "Contract added to project: [#form.project_name#]">
				</cfif>
			<cfelse>
				<cfset message = message & ' (already in the database)'>
			</cfif>
		</cfif>

		<cfcatch type = "any">
			<cfoutput>
				<cfset error = "<p>Caught an exception, type = #CFCATCH.TYPE#</p><p>#cfcatch.message#</p>">
				<cfif len(cfcatch.detail) gt 0>
					<cfset error =  error & "<p>The details are:</p>#cfcatch.detail#">
				</cfif>
			</cfoutput>
		</cfcatch>
	</cftry>

	<cfif len(message) gt 0>
		Messages: #message#<br>
	</cfif>

	<cfif len(error) gt 0>
		Errors: #error#<br>
	</cfif>

	</cfoutput>
	</div>
</div>
<cfinclude template="footer.html">
</body>
</html>
