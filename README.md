# Automatic Near Real-time Oil Spill Detection from Sentinel-1 Data

The pipeline consists of 5 packages:
1. Data Search
2. Preprocessing
3. ML Object Detection
4. ML Segmentation
5. Snappy Segmentation

Packages 4 and 5 generate oil spill binary masks in different ways. We include both for comparison purposes.

Packages can be used separately by running every cwl file, or all together by running the entire pipeline.

## Prerequisites
To be able to run this CWL flow you need to have available on your machine:

1. Python
2. Docker
3. CWLTool

The flow also requires credentials for:
* [ASF Search platform](https://search.asf.alaska.edu/#/) to search for Sentinel-1 images.
* ***dockerPull*** of flow dockers (to contact key person at MEEO - fazzini@meeo.it)

## Run Common Workflow Language (CWL) pipeline
The Common Workflow Language (CWL) is an open standard designed to enable the description of analysis workflows and tools in a portable, scalable, and reproducible manner. CWL workflows are typically written in YAML and require a CWL-compliant runner to execute (here we use ***cwltool*** library).

Use ***dockerPull*** field in the CWL file to specify the name of a Docker image from a container registry.

CWL can be used for both single application packages and multi-step pipelines. 

To run a single CWL flow you have to execute the following command:

### Application package 1
```bash
cwltool oilspill001.cwl#datasearch_tool oilspill001.yaml
```

* oilspill001.cwl is the path to the cwl workflow file
* datasearch_tool is the name of the workflow class to be executed
* oilspill001.yaml is the path to the file with the json that has the input variables of the workflow

The other application packages can be executed using the commends:
### Application package 2
```bash
cwltool oilspill002.cwl#preprocessing_tool oilspill002.yaml
```
### Application package 3
```bash
cwltool oilspill003.cwl#object_detection_tool oilspill003.yaml
```
### Application package 4
```bash
cwltool oilspill004.cwl#segmentation_tool oilspill004.yaml
```
### Application package 5
```bash
cwltool oilspill005.cwl#snappy_extraction_tool oilspill005.yaml
```

To run the entire CWL flow you have to execute one of following commands:
### Oilspill Pipeline 1-2-3-4
```bash
cwltool oilspill_pipeline.cwl#oilspill_pipeline oilspill_pipeline.yaml
```

### Oilspill Pipeline 1-2-3-5
```bash
cwltool oilspill_pipeline15.cwl#oilspill_pipeline15 oilspill_pipeline.yaml
```

### Oilspill Pipeline 1-2-3-4-5
```bash
cwltool oilspill_pipeline145.cwl#oilspill_pipeline145 oilspill_pipeline.yaml
```