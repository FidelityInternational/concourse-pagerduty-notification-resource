pagerduty resource
==================

Sends alerts to pagerduty

Resource Type Configuration
---------------------------

```
resource_types:
- name: pagerduty-notification
  type: docker-image
  source:
    repository: fidelityinternational/pagerduty-notification-resource
    tag: latest
```

Source Configuration
--------------------

- `service_key`: *Required*. The GUID of one of your "Generic API" services. This is the "Integration Key" listed on a Generic API's service detail page.

```
resources:
- name: pagerduty-alert
  type: pagerduty-notification
  source:
    service_key: <your_service_key>
```

Behavior
--------

### `out`: Sends alert to pagerduty.

Send alert to pagerduty, with the configured parameters.

#### Parameters

Required:
- `description`: Static text of alert to send

Example
-------

```
resource_types:
- name: pagerduty-notification
  type: docker-image
  source:
    repository: fidelityinternational/pagerduty-notification-resource
    tag: latest

resources:
- name: pagerduty-alert
  type: pagerduty-notification
  source:
    service_key: <your_service_key>

jobs:
- name: example-alert
  - put: pagerduty-alert
    params:
      description: "an example alert"
```

