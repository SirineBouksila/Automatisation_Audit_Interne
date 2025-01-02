import os
import glob
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.operators.empty import EmptyOperator
from airflow.decorators import task

dag_path = os.path.join(os.path.dirname(__file__))
dag_name = os.path.basename(__file__).replace('.py', '')
data_csv_directory = f'{dag_path}/../data_csv'

default_args = {
    'owner': 'alonso_md',
    'retries': 5,
    'retry_delay': timedelta(minutes=1)
}

with DAG(
    dag_id=dag_name,
    start_date=datetime(2022, 9, 10),
    schedule_interval='*/45 * * * *',  # Exécution toutes les 30 minutes
    default_args=default_args,
    catchup=False,
    max_active_runs=1
) as dag:
    
    start = EmptyOperator(task_id='start')
    end = EmptyOperator(task_id='end')
    
    @task(task_id="copy_csv_files_to_s3")
    def copy_csv_files_to_s3():
        s3_hook = S3Hook()

        # Liste tous les fichiers CSV dans le répertoire source
        for file_path in glob.glob(f'{data_csv_directory}/**/*.csv', recursive=True):
            s3_key = os.path.relpath(file_path, data_csv_directory)  # Utilise le chemin relatif pour la clé S3
            
            # Charge les fichiers sur S3, remplaçant ceux déjà existants (mise à jour)
            s3_hook.load_file(
                filename=file_path,
                bucket_name='raw',
                key=s3_key,
                replace=True  # Remplace le fichier existant sur S3
            )
            print(f"File {file_path} successfully uploaded to S3 as {s3_key}")
    
    start >> copy_csv_files_to_s3() >> end
