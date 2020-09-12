CREATE OR REPLACE PROCEDURE dbo."up_api_AssociateUserAccountAdd1"
(
    IN    pi_DomainName     			VARCHAR(255),
	IN 	  pi_UserId						INTEGER,
	IN    pi_CustomerId					INTEGER,
	IN    pi_NortonGuid					VARCHAR(36),
    IN 	  pi_NslEmailAddress			VARCHAR(100),
    IN    pi_SsoProvider				INTEGER,
	INOUT po_AssociateUserAccountOk		BOOLEAN,
    INOUT po_ReturnValue  				INTEGER,
    INOUT rc_ResultSet    				REFCURSOR
)
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE 
			v_ErrorMessage 	TEXT;
			v_ErrorDetail   TEXT;
			v_ErrorContext  TEXT;
			v_ErrorSeverity INTEGER;
			v_ErrorState 	INTEGER;
			v_ErrorNumber 	INTEGER; 
			v_ErrorLine 	INTEGER;
			v_ObjectName  	VARCHAR(128);
			v_ErrorHint     VARCHAR(20);
			
BEGIN

    v_ObjectName := 'up_api_AssociateUserAccountAdd';
	IF pi_SsoProvider<>1
    THEN
		v_ErrorNumber  := 99020;
   		v_ErrorMessage := '**>> ERROR(' || coalesce(v_ObjectName, '') ||
                          '): error code ['|| CAST(v_ErrorNumber AS VARCHAR)|| '] Specified SsoProvider should be = 1' ;

    	RAISE EXCEPTION '%',v_ErrorMessage;
    END IF;
	
	IF EXISTS 
		(
			SELECT A.*
			  FROM dbo."AuthorisedUserLinkedAccount" A
		RIGHT JOIN dbo."AuthorisedUser" AU
				ON A."UserId" = pi_UserId
			  JOIN dbo."CustomerPwdPolicy" CP
				ON AU."CustomerId" = CP."CustomerId"
			 WHERE CP."AllowNslLinking" = TRUE				--TRUE
			   AND AU."userid" = pi_UserId
			   AND A.NortonGuid IS NULL 
		) 
	THEN 	   
	
		INSERT INTO dbo."AuthorisedUserLinkedAccount"
		(
				UserId, 
				NortonGuid, 
				NslEmailAddress, 
				DateCreated, 
				DateAmended, 
				WhoAmended_nt_username, 
				WhoAmended_hostname, 
				SsoProvider
		)
		VALUES
		(	
			pi_UserId, 
			pi_NortonGuid, 
			pi_NslEmailAddress, 
			NOW(), 
			NOW(), 
			'User=' || CAST(pi_UserId AS varchar), 
			HOST_NAME(), 
			pi_SsoProvider);

			po_AssociateUserAccountOk := TRUE  ;
		
	ELSE
		
		po_AssociateUserAccountOk := FALSE ;
		
	END IF;
	
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
		
	
	