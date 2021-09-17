"""ETL implementation for TD Sunset Agreement project, AIF-RPS"""
from typing import Any
from typing import Dict
from typing import cast

from generic_etl.generic_etl import GenericETL
from generic_etl.mdc.model import ETLStep
from generic_etl.common.vertica_utils import VerticaUtils

ETL_PROJECT_NAME = "AIF_RPS"

class AifRpsETL(GenericETL):
    """TD Sunset AIF-RPS ETL application, inherit common functionalities from GenericETL class."""

    def __init__(
            self,
            db_host: str,
            db_port: int,
            db_name: str,
            db_user: str,
            db_password: str,
            mdc_schema: str,
            audit_schema: str,
            etl_step: str,
            job_scheduler: str,
            support_email_address: str,
            trans_dt: str,
            source_dataset_ids: str,
            mapping_ids: str,
            debug_mode: bool = False,
            dry_run: bool = False,
            sql_identifiers: Dict[str, Any] = {},
    ) -> None:
        """Teradata Agreement ETL application, inherit common functionalities from GenericETL class."""
        super().__init__(
            db_host,
            db_port,
            db_name,
            db_user,
            db_password,
            mdc_schema,
            audit_schema,
            ETL_PROJECT_NAME,
            etl_step,
            job_scheduler,
            support_email_address,
            trans_dt=trans_dt,
            source_dataset_ids=source_dataset_ids,
            mapping_ids=mapping_ids,
            debug_mode=debug_mode,
            dry_run=dry_run,
            sql_identifiers=sql_identifiers,
        )
        """Generate a TeraDataAgreementETL object.

        :param db_host: edw server hostname.
        :param db_port: edw server port number.
        :param db_name: edw database name.
        :param db_user: edw batch user for this project.
        :param db_password: password for the edw batch user.
        :param mdc_schema: schema name for the metadata catalog.
        :param job_scheduler: job scheduler name (Jenkins, Airflow, etc.
        :param support_email_address: project supporter email address.
        :param debug_mode: If True, log_level = DEBUG
        :param dry_run: Dry run the ETL project, will NOT do any update on DB.
        :param sql_identifiers: Parameter for database schema
        """

        self._etl_param_values = cast(Dict[str, Any], {})
        self.STAGING_SCHEMA = "edw_staging"

    def run(self):
        """Execute the ETL step."""
        with self.get_connection() as conn:
            #self._create_new_batch_and_step_audit(conn)
            """Kick off the transformation job."""
            if self.run_all_steps:
                self.run_all()
            else:
                self.skipped_steps = []
                self.skipped_tables = []
                step_runner = self.step_lambda_map[self.etl_step]
                step_runner()
