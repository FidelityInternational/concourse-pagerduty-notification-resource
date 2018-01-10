Concourse Pagerduty Notification Resource
==================

Sends alerts to Pagerduty.
This resource can now send log output of failing Concourse task(s) to Pagerduty, as well as the standard `description` and `incident_key` fields.

Resource Type Configuration
---------------------------

```
resource_types:
- name: pagerduty-notification-resource
  type: docker-image
  source:
    repository: fidelityinternational/pagerduty-notification-resource
    tag: latest
```

Source Configuration
--------------------

- `pd_service_key`: *Required*. The GUID of one of your "Generic API" services. This is the "Integration Key" listed on a Generic API's service detail page.

The following fields are required if you want to see erroring Concourse task output in the Pagerduty notification:

- atc_external_url: *Optional* The ATC external URL (if username and password is supplied but not the ATC URL, it will attempt to use the standard in-built ATC_EXTERNAL_URL instead)
- atc_username: *Optional* ATC username is required if atc_external_url is supplied.
- atc_password: *Optional* ATC password is required if atc_external_url is supplied.


Example resource config:
```
resources:
- name: pagerduty-notify
  type: pagerduty-notification-resource
  source:
    atc_external_url: ...
    atc_username: ...
    atc_password: ...
    pd_service_key: ...
```

Behaviour
--------

### `out`: Sends alert to pagerduty.

Send alert to pagerduty with the configured parameters.

#### Parameters

Required:
- `description`: Static text of alert to send

Optional:
- `incident_key`: Provides an incident key that can be used to dedupe alerts

Example
-------

See our sample [pipeline.yml](pipeline.yml) for a working example.

Testing
-------

To test this resource, install a test Concourse with Docker following [the guide here](https://concourse.ci/docker-repository.html).

Push the sample pipeline to it (remember to update the Pagerduty resource configuration options first, as appropriate):

```
fly login -t local -c http://localhost:8080 -u concourse -p changeme
fly -t local set-pipeline -p test -c pipeline.yml
```

Browse http://localhost:8080 and run the monitoring-test job. One of the tasks in that job is supposed to succeed, and one is supposed to fail. Note the Pagerduty put: on the failing job. This should now trigger, so check your Pagerduty account for an incoming alert.

Inside the alert message you should find pipeline, job_name, concourse_build_url and output fields which contain useful error messages.
