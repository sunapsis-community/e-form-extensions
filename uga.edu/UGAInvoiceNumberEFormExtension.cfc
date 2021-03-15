<cfcomponent extends="istart.core.EFormExtension">
	<cffunction name="cleanup" access="public">
		<cfargument name="identifier" type="istart.core.Identifier" required="true">
		<cfargument name="action" type="istart.core.FormAction" required="true">
		<cfargument name="formObject" type="istart.core.FormObject" required="true">
		<cfargument name="serviceID" type="string" required="true">
		<cfargument name="eformTitle" type="string" required="true">
		<cfargument name="response" type="istart.core.ActionResponse" required="true">

		<cftry>
			<!--Grab the recnum from the formObject, which should be populated at this times-->
			<cfset invoiceEformRecnum = formObject.getElement("recnum").getValue()>
			
			<!--Find the eform entry in the database and grab it's data information-->
			<cfquery name="invoiceEform">
				select top 1 recnum, data
				from jbeform
				where recnum = <cfqueryparam cfsqltype="cf_sql_integer" value=#invoiceEformRecnum#>
			</cfquery>
			
			<!--Create and XML object from the data, search for the datum labelled Invoice Number and set the found element's xmlText to the recnum value-->
			<cfset invoiceEformXML = XmlParse(invoiceEform.data)>
			<cfset invoiceNumberElement = XmlSearch(invoiceEformXML, "/data/dataObject/datums/datum[@label='Invoice Number']/value")>
			<cfif ArrayIsDefined(invoiceNumberElement, 1) >
				<cfset invoiceNumberElement[1].xmlText = invoiceEformRecnum>
				
				<!--Update the jbeform table row with the newly inserted invoice number-->
				<cfquery name="updateInvoiceNumber">
					update jbeform
					set data = <cfqueryparam cfsqltype="cf_sql_varchar" value=#invoiceEformXML#>
					where recnum = <cfqueryparam cfsqltype="cf_sql_integer" value=#invoiceEformRecnum#>
				</cfquery>
			</cfif>

			<cfcatch>
				<cfmail spoolenable="no" to="mrcooper@uga.edu" from="istart@uga.edu" subject="error in cleanup for invoice number">
					#formObject#
					<cfdump var="#cfcatch#" format="text">
				</cfmail>
			</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>
