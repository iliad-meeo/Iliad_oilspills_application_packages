cwlVersion: v1.2

$namespaces:
  s: https://schema.org/


$graph:

- baseCommand: 
    - /srv/miniconda3/envs/oilspill003/bin/python  
    - -m
    - oilspill003.main  
  class: CommandLineTool

  id: object_detection_tool

  arguments:
    - --use-case-directory
    - valueFrom: "$(inputs.use_case_directory.path)"
    - --db-list
    - valueFrom: "$(inputs.db_list.path)"
    - valueFrom: |
        ${ return inputs.range ? '--range' : ''; }
      shellQuote: false
    - valueFrom: |
        ${ return inputs.verbose ? '--verbose' : ''; }
      shellQuote: false
    - valueFrom: |
        ${ return inputs.debug ? '--debug' : ''; }
      shellQuote: false

  inputs:
    use_case_directory:
      type: Directory
      doc: Directory where to find input files and store outputs
      s:name: Use Case Directory
      s:description: Directory to store input and output files.
    db_list:
      type: File
      doc: .txt file containing paths of preprocessed sentinel-1 images (output from application package 2) - db_paths.txt
      s:name: Db list file
      s:description: .txt file containing paths of preprocessed sentinel-1 images (output from application package 2) - db_paths.txt
    range:
      type: string?
      doc: optional range 0-100 for image contrast enhancement
      s:name: Range
      s:description: optional range 0-100 for image contrast enhancement
    verbose:
      type: boolean?
      doc: Enable verbose logging
      s:name: Verbose Logging
      s:description: Flag to enable verbose logging.
    debug:
      type: boolean?
      doc: Enable debug mode
      s:name: Debug Mode
      s:description: Flag to enable debug mode for additional logging.

  outputs:
    results:
      type: Directory
      doc: Directory containing the results
      outputBinding:
        glob: "$(inputs.use_case_directory.path)"
      s:name: Results Directory
      s:description: The directory containing the outputs of the object detection step.

  requirements:
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)  
          writable: true 
          entry: $(inputs.use_case_directory)
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/iliad/iliad_oil_spill_pilot/oilspill003:2.0.0  
    - class: NetworkAccess
      networkAccess: true
    - class: InlineJavascriptRequirement

  s:name: Sentinel-1 Oil Spill Object Detection Pipeline
  s:description: Deep learning model designed for detecting oil spill signals globally from pre-processedSAR images from Sentinel-1.
  s:keywords:
  - oil spill
  - SAR
  - Sentinel-1
  - deep learning
  - object detection
  s:programmingLanguage: python
  s:softwareVersion: 1.0.0
  s:publisher:
    class: s:Organization
    s:name: MEEO SRL
    s:url: https://meeo.it/
    s:address:
      class: s:PostalAddress
      s:addressCountry: IT
  s:sourceOrganization:
    - class: s:Organization
      s:name: MEEO SRL
      s:url: https://meeo.it/
      s:address:
        class: s:PostalAddress
        s:addressCountry: IT
    - class: s:Organization
      s:name: FORTH
      s:url: https://www.forth.gr/
      s:address:
        class: s:PostalAddress
        s:addressCountry: GR
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:author:
    - class: s:Person
      s:email: outmani@meeo.it
      s:name: Sabrina Outmani
    - class: s:Person
      s:email: fazzini@meeo.it
      s:name: Noemi Fazzini
  s:dateCreated: "2024-12-01"
  s:temporalCoverage: "2014-01-01T00:00:00Z/"
  s:spatialCoverage:
    class: s:GeoShape
    s:box: "-90 -180 90 180"
  s:license: https://opensource.org/licenses/MIT
  s:citation: ""

