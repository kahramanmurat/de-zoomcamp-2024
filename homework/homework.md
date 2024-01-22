## Module 1 Homework

## Docker & SQL

In this homework we'll prepare the environment 
and practice with Docker and SQL


## Question 1. Knowing docker tags

Run the command to get information on Docker 

```docker --help```

Now run the command to get help on the "docker build" command:

```docker build --help```

Do the same for "docker run".

Which tag has the following text? - *Automatically remove the container when it exits* 

- `--delete`
- `--rc`
- `--rmc`
- `--rm`

>Answer: 

```
--rm
```


## Question 2. Understanding docker first run 

Run docker with the python:3.9 image in an interactive mode and the entrypoint of bash.
Now check the python modules that are installed ( use ```pip list``` ). 

What is version of the package *wheel* ?

- 0.42.0
- 1.0.0
- 23.0.1
- 58.1.0

>Answer: `0.42.0`

First run the docker image below:

```
docker run -it --entrypoint bash python:3.9
```

Run the command below:

>Command:

```
pip list
```

# Prepare Postgres

Run Postgres and load data as shown in the videos
We'll use the green taxi trips from September 2019:

```wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz```

You will also need the dataset with zones:

```wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv```

Download this data and put it into Postgres (with jupyter notebooks or with a pipeline)

Run Postgres and load data as shown in the videos

>Command

```
docker-compose up
```

We'll use the green taxi trips from September 2019:

```wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz```

You will also need the dataset with zones:

```wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv```

>Command:
```bash
# Create a new ingest script that ingests both files called ingest_data.py, then dockerize it with

docker build -t taxi_ingest:v001 .

# Now find the network where the docker-compose containers are running with
docker network ls

# Finally, run the dockerized script
docker run -it --network=homework_default  taxi_ingest:v001 --user=USER --password=PASSWORD --host=pgdatabase --port=5432 --db=ny_taxi --table_name=green_taxi_trips --url=${URL}
```

## Question 3. Count records 

How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18. 

Remember that `lpep_pickup_datetime` and `lpep_dropoff_datetime` columns are in the format timestamp (date and hour+min+sec) and not in date.

- 15767
- 15612
- 15859
- 89009

Answer: `15612`

>Command:
```sql
SELECT
COUNT(*)
FROM
green_taxi_trips
WHERE DATE(lpep_pickup_datetime)='2019-09-18' AND DATE(lpep_dropoff_datetime)='2019-09-18';
```

## Question 4. Largest trip for each day

Which was the pick up day with the largest trip distance
Use the pick up time for your calculations.

- 2019-09-18
- 2019-09-16
- 2019-09-26
- 2019-09-21

Answer: `2019-09-26`

>Command:

```sql
SELECT 
lpep_pickup_datetime, 
trip_distance
FROM green_taxi_trips
ORDER BY trip_distance DESC;
```

## Question 5. Three biggest pick up Boroughs

Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?
 
- "Brooklyn" "Manhattan" "Queens"
- "Bronx" "Brooklyn" "Manhattan"
- "Bronx" "Manhattan" "Queens" 
- "Brooklyn" "Queens" "Staten Island"

Answer: `"Brooklyn" "Manhattan" "Queens"`
>Command
```sql 
SELECT zpu."Borough",SUM(total_amount) AS total_amount_sum
FROM green_taxi_trips gtt JOIN zones zpu ON gtt."PULocationID"=zpu."LocationID"
WHERE DATE(lpep_pickup_datetime) = '2019-09-18' AND zpu."Borough" IS NOT NULL
GROUP BY zpu."Borough"
HAVING SUM(total_amount) > 50000
ORDER BY total_amount_sum DESC
LIMIT 3;
```


## Question 6. Largest tip

For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip?
We want the name of the zone, not the id.

Note: it's not a typo, it's `tip` , not `trip`

- Central Park
- Jamaica
- JFK Airport
- Long Island City/Queens Plaza

Answer: `JFK Airport`

>Command:
```sql
WITH CTE AS (
    SELECT 
        gtt."PULocationID" AS PULocationID,
        zpu."Zone" AS pick_up_zone,
        gtt."DOLocationID" AS DOLocationID,
        zdo."Zone" AS drop_off_zone,
        gtt.tip_amount AS tip_amount,
        RANK() OVER (PARTITION BY gtt."PULocationID" ORDER BY gtt.tip_amount DESC) AS rnk
    FROM
        green_taxi_trips gtt
        JOIN zones zpu ON gtt."PULocationID" = zpu."LocationID"
        JOIN zones zdo ON gtt."DOLocationID" = zdo."LocationID"
    WHERE zpu."Zone" = 'Astoria'
)
SELECT 
    pick_up_zone,
    drop_off_zone,
    tip_amount
FROM
    CTE
WHERE rnk = 1;
```

## Terraform

In this section homework we'll prepare the environment by creating resources in GCP with Terraform.

In your VM on GCP/Laptop/GitHub Codespace install Terraform. 
Copy the files from the course repo
[here](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/01-docker-terraform/1_terraform_gcp/terraform) to your VM/Laptop/GitHub Codespace.

Modify the files as necessary to create a GCP Bucket and Big Query Dataset.


## Question 7. Creating Resources

After updating the main.tf and variable.tf files run:

```
terraform apply
```

Paste the output of this command into the homework submission form.

>Answer:
```
terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.homework_dataset will be created
  + resource "google_bigquery_dataset" "homework_dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "homework_dataset"
      + default_collation          = (known after apply)
      + delete_contents_on_destroy = false
      + effective_labels           = (known after apply)
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + is_case_insensitive        = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "US"
      + max_time_travel_hours      = (known after apply)
      + project                    = "ny-taxi-2024"
      + self_link                  = (known after apply)
      + storage_billing_model      = (known after apply)
      + terraform_labels           = (known after apply)
    }

  # google_storage_bucket.homework_bucket will be created
  + resource "google_storage_bucket" "homework_bucket" {
      + effective_labels            = (known after apply)
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "US"
      + name                        = "ny-taxi-2024-homework-bucket"
      + project                     = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = (known after apply)
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "Delete"
            }
          + condition {
              + age                   = 30
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.homework_dataset: Creating...
google_storage_bucket.homework_bucket: Creating...
google_bigquery_dataset.homework_dataset: Creation complete after 1s [id=projects/ny-taxi-2024/datasets/homework_dataset]
google_storage_bucket.homework_bucket: Creation complete after 1s [id=ny-taxi-2024-homework-bucket]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

## Submitting the solutions

* Form for submitting: https://courses.datatalks.club/de-zoomcamp-2024/homework/hw01
* You can submit your homework multiple times. In this case, only the last submission will be used. 

Deadline: 29 January, 23:00 CET

