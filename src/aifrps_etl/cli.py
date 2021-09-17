"""CLI entrypoint for aifrps_etl.

Usage:
    aifrps_etl --help
    aifrps_etl [options]

Options:
  -h --help                         Show this screen
  --db-host=HOST                    EDW Vertca hostname
  --db-port=PORT                    EDW Vertica port number.
  --db-name=DB_NAME                 EDW Database name.
  --db-user=DB_USER                 Project batch user name.
  --db-password=DB_PASSWORD         Project batch user password.
  --mdc-schema=MDC_SCHEMA           Metadata catalog Vertica schema
  --audit-schema=AUDIT_SCHEMA       Vertica schema name of edw audit tables. [default: edw_audit].
  --etl-step=ETL_STEP               ETL step: all, staging, pre_transform_check, transform, merge, post_steps.
  --job-scheduler=JOB_SCHEDULER     Job scheduler: jenkins, manual, airflow, etc.
  --support-email-address=EMAIL     Supporter email address.
  --trans-dt=TRANS_DT               Need to be passed when process old batch to indicate source date.[default:].
  --source-dataset-ids=None         Support for specific dataset.
  --mapping-ids=None                Support for specific dataset.
  --log-level=DEBUG                 if set, log_level=DEBUG
  --dry-run                         Dry run the ETL project,will NOT do any update on DB.
  --initial-load                    Run through initial load logic, [default: False].
  --init-load-list=INIT_LOAD_LIST   Table list to pass to process to do initial load.
  --init-load-type=INIT_LOAD_TYPE   Initial process using 'r' for run_id, 't' for trans_id.
  --init-load-restart=False         Initial process if True it will skip truncating snapshot tables when restarting any failures
  --sql-identifiers=Dict[str, Any]  Pass schema names and value
"""


import logging

from docopt import docopt
import json

from aifrps_etl.aifrps_etl import AifRpsETL
from aifrps_etl.initial_load import AifRpsETLInitialLoad
from aifrps_etl.utils import unpack_sql_into_cwd


def main():
    """TD Sunset AIF-RPS ETL application Entrypoint."""
    args = docopt(__doc__)
    log_level = logging.INFO if args["--log-level"].upper() == "INFO" else logging.DEBUG
    logging.basicConfig(format="%(asctime)s %(levelname)s: %(message)s", level=log_level)
    debug_mode = log_level is logging.DEBUG

    # SQl Identifier Parameter parsing Json input
    json_input = args["--sql-identifiers"]
    if json_input is not None:
        sql_identifiers_a = json.loads(args["--sql-identifiers"])
        args["--sql-identifiers"] = sql_identifiers_a

    unpack_sql_into_cwd(package_name=__name__.split(".")[0])
    # convert string value to int before passing to GenericETL
    dataset_ids = args["--source-dataset-ids"]
    if dataset_ids is not None:
        dataset_ids_list = dataset_ids.split(",")
        dataset_ids_set = {int(id) for id in dataset_ids_list}
        args["--source-dataset-ids"] = dataset_ids_set

    # convert string value to int for mapping_id
    mapping_ids = args["--mapping-ids"]
    if mapping_ids is not None:
        m_id_list = mapping_ids.split(",")
        m_id_set = {int(id) for id in m_id_list}
        args["--mapping-ids"] = m_id_set

    initial_load_list = args["--init-load-list"]
    if initial_load_list is not None:
        i_load_list = initial_load_list.split(",")
        i_loadlist_set = {tbl for tbl in i_load_list}
        args["--init-load-list"] = i_loadlist_set

    initial_load_type = args["--init-load-type"]
    # this is a single char or None
    if initial_load_type is not None:
        args["--init-load-type"] = initial_load_type

    init_load_restart = args["--init-load-restart"]
    if init_load_restart is not None:
        args["--init-load-restart"] = init_load_restart

    if not args["--initial-load"]:
        aifrps = AifRpsETL(
            db_host=args["--db-host"],
            db_port=args["--db-port"],
            db_name=args["--db-name"],
            db_user=args["--db-user"],
            db_password=args["--db-password"],
            mdc_schema=args["--mdc-schema"],
            audit_schema=args["--audit-schema"],
            etl_step=args["--etl-step"],
            job_scheduler=args["--job-scheduler"],
            support_email_address=args["--support-email-address"],
            trans_dt=args["--trans-dt"],
            source_dataset_ids=args["--source-dataset-ids"],
            mapping_ids=args["--mapping-ids"],
            debug_mode=debug_mode,
            dry_run=args["--dry-run"],
            sql_identifiers=args["--sql-identifiers"],
        )
    else:
        aifrps = AifRpsETLInitialLoad(
            db_host=args["--db-host"],
            db_port=args["--db-port"],
            db_name=args["--db-name"],
            db_user=args["--db-user"],
            db_password=args["--db-password"],
            init_load_list=args["--init-load-list"],
            init_load_type=args["--init-load-type"],
            init_load_restart=args["--init-load-restart"],
            debug_mode=debug_mode,

        )

    aifrps.run()


if __name__ == "__main__":
    main()
