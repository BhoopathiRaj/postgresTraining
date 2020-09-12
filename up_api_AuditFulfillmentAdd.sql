CREATE OR REPLACE PROCEDURE dbo."up_api_AuditFulfillmentAdd"
(
	IN pi_JsonHash					CHAR(64),
	IN pi_SfdcId					varchar(64),
	IN pi_ResellerSfdcId			varchar(64),
	IN pi_Json					TEXT,
	IN pi_EpmpCustomerId			varchar(255),
	IN pi_EpmpDomainId				varchar(255),
	IN pi_FulfillmentStatus			int,
	IN pi_FailureReason				varchar(1024),
	IN pi_TransactionReasonCode		varchar(32),
	IN pi_FeatureCode				varchar(32),
	IN pi_SalesChannel				varchar(32),
	IN pi_OrderedQuantity			int,
	IN pi_CustomerId				int,
	IN pi_ResellerId				int,
	IN pi_TemplateMatrixId			int,
	IN pi_Hostname					varchar(100),
	IN pi_SourceSystem				varchar(50),
	INOUT po_AuditFulfillmentId		int	= 0	OUTPUT
	INOUT po_ReturnValue  			INTEGER,
    INOUT rc_ResultSet    			REFCURSOR
)
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE
    v_ErrorState         VARCHAR(10);
    v_ErrorMessage       TEXT;
    v_ErrorDetail        TEXT;
    v_ErrorHint          VARCHAR(20);
    v_ErrorContext       TEXT;
    v_ErrorNumber        VARCHAR(10);
    v_ObjectName         VARCHAR(128);
	
	v_ErrorNumber	:= 99020;
	v_ErrorMessage	:= '**>> ERROR(' || coalesce(v_ObjectName, '')||'): inserting AuditFulfillment' ;
	RAISE EXCEPTION '%',v_ErrorMessage;
			
			
	INSERT INTO  [InsightAudit].dbo."AuditFulfillment"
	(
		JsonHash,
		SfdcId,
		ResellerSfdcId,
		Json,
		EpmpCustomerId,
		EpmpDomainId,
		FulfillmentStatus,
		FailureReason,
		TransactionReasonCode,
		FeatureCode,
		SalesChannel,
		OrderedQuantity,
		CustomerId,
		ResellerId,
		TemplateMatrixId,
		ActionTime,
		Hostname,
		SourceSystem 
	)
	VALUES
	(
		pi_JsonHash,
		pi_SfdcId,
		pi_ResellerSfdcId,
		pi_Json,
		pi_EpmpCustomerId,
		pi_EpmpDomainId,
		pi_FulfillmentStatus,
		pi_FailureReason,
		pi_TransactionReasonCode,
		pi_FeatureCode,
		pi_SalesChannel,
		pi_OrderedQuantity,
		pi_CustomerId,
		pi_ResellerId,
		pi_TemplateMatrixId,
		NOW(),
		pi_Hostname,
		pi_SourceSystem
	);
	
	po_AuditFulfillmentId := 0;

    po_ReturnValue := 0;
    RETURN;

EXCEPTION
	WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS	
		    v_ErrorState = RETURNED_SQLSTATE,
            v_ErrorMessage = MESSAGE_TEXT,
            v_ErrorDetail = PG_EXCEPTION_DETAIL,
            v_ErrorContext = PG_EXCEPTION_CONTEXT;
	 	
		 IF v_ErrorState = 'P0001'
        THEN
            v_ErrorState := v_ErrorNumber;
            v_ErrorHint := 'Application Error';
        ELSE
            v_ErrorHint := 'System Error';
            v_ErrorMessage := '**>> ERROR(' || coalesce(v_ObjectName, '') || '): ' || v_ErrorMessage;
        END IF;

        RAISE EXCEPTION E'
        state  : %
        message: %
        detail : %
        hint   : %
        context: %', v_ErrorState, v_ErrorMessage, v_ErrorDetail, v_ErrorHint, v_ErrorContext;
        po_ReturnValue := v_ErrorState;
        RETURN;
END;
$BODY$;
			