cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool

$graph:

- class: Workflow
  id: oilspill_pipeline
  doc: Oil Spill Detection and Analysis Pipeline 1-2-3-4

  inputs:
    use_case_directory:
      doc: Path to directory as a string where to find input files and where to store outputs
      type: string
    bbox:
      doc: Bounding box for image search
      type: string?
    start_date:
      doc: Start date for data search
      type: string?
    time_interval:
      doc: Time interval (n of days) for data search
      type: int?
    end_date:
      doc: End date for data search
      type: string?
    verbose:
      doc: Enable verbose logging
      type: boolean?
    debug:
      doc: Enable debug mode
      type: boolean?
    asf_username:
      type: string
    asf_password:
      type: string

  steps:
    step_data_search:
      in:
        bbox: bbox
        use_case_directory: use_case_directory
        start_date: start_date
        time_interval: time_interval
        end_date: end_date
        verbose: verbose
        debug: debug
        asf_username: asf_username
        asf_password: asf_password
      run: "#datasearch_tool"
      out:
        - results
        - sentinel_list

    step_preprocessing:
      in:
        use_case_directory: step_data_search/results
        sentinel_list: step_data_search/sentinel_list  
        verbose: verbose
        debug: debug
      run: "#preprocessing_tool"
      out:
        - results
        - db_list

    step_object_detection:
      in:
        use_case_directory: step_preprocessing/results
        db_list: step_preprocessing/db_list
        verbose: verbose
        debug: debug
      run: "#object_detection_tool"
      out:
        - results
        - png_output_path
        - csv_output_path

    step_segmentation:
      in:
        use_case_directory: step_object_detection/results
        sentinel_list: step_data_search/sentinel_list  
        png_output_path: step_object_detection/png_output_path
        csv_output_path: step_object_detection/csv_output_path
        verbose: verbose
        debug: debug
      run: "#segmentation_tool"
      out:
        - results

  outputs:
    pipeline_output:
      type: Directory
      outputSource: step_segmentation/results

  s:name: Sentinel-1 Oil Spill Object Detection Pipeline 1-2-3-4
  s:description: Sentinel-1 Oil Spill Object Detection Pipeline using Deep Learning tecniques
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


- class: CommandLineTool
  
  id: datasearch_tool

  baseCommand:
    - /srv/miniconda3/envs/oilspill001/bin/python
    - -m
    - oilspill001.main
  
  arguments:
    - valueFrom: "$(inputs.bbox)"
      prefix: "--bbox"
    - --use-case-directory
    - valueFrom: "$(inputs.use_case_directory)"
    - --start-date
    - valueFrom: "$(inputs.start_date)"
    - valueFrom: "$(inputs.time_interval)"
      prefix: "--time-interval"
    - valueFrom: "$(inputs.end_date)"
      prefix: "--end-date"
    - valueFrom: "$(inputs.verbose)"
      prefix: "--verbose"
    - valueFrom: "$(inputs.debug)"
      prefix: "--debug"
    - --asf-username
    - valueFrom: "$(inputs.asf_username)"
    - --asf-password
    - valueFrom: "$(inputs.asf_password)"
  
  inputs:
    bbox:
      type: string?
      doc: Bounding box for image search
      s:name: Bounding Box
      s:description: Optional bounding box to restrict the image search.
    use_case_directory:
      type: string
      doc: Directory where to find input files and store outputs
      s:name: Use Case Directory
      s:description: Directory to store input and output files.
    start_date:
      type: string?
      doc: Start date for data search
      s:name: Start Date
      s:description: The start date to search for data.
    time_interval:
      type: int?
      doc: Time interval (n of days) for data search
      s:name: Time Interval
      s:description: Number of days for the data search interval.
    end_date:
      type: string?
      doc: End date for data search
      s:name: End Date
      s:description: The end date for data search (optional).
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
    asf_username:
      type: string
      doc: Username for ASF
      s:name: ASF Username
      s:description: Username for the ASF platform authentication.
    asf_password:
      type: string
      doc: Password for ASF
      s:name: ASF Password
      s:description: Password for the ASF platform authentication.

  outputs:
    results:
      type: Directory
      outputBinding:
        glob: $(inputs.use_case_directory)
    sentinel_list:
      type: File
      outputBinding:
        glob: $(inputs.use_case_directory)/raw_sentinel/sentinel_paths.txt
  
  requirements:
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/iliad/iliad_oil_spill_pilot/oilspill001:1.0.0
    - class: NetworkAccess
      networkAccess: true
    - class: InlineJavascriptRequirement
  
  s:name: Sentinel-1 Oil Spill Detection Data Search
  s:description: ASF search for SAR images from Sentinel-1
  s:keywords:
    - oil spill
    - SAR
    - Sentinel-1
    - ASF
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
      s:name: Sabrina Outmani
      s:email: outmani@meeo.it
    - class: s:Person
      s:name: Noemi Fazzini
      s:email: fazzini@meeo.it
  s:dateCreated: "2024-12-01"
  s:temporalCoverage: "2014-01-01T00:00:00Z/"
  s:spatialCoverage:
    class: s:GeoShape
    s:box: "-90 -180 90 180"
  s:codeRepository: 
  s:license: https://opensource.org/licenses/MIT
  s:citation: ""

- class: CommandLineTool
  
  id: preprocessing_tool

  baseCommand:
    - /srv/miniconda3/envs/oilspill002/bin/python
    - -m
    - oilspill002.main
  arguments:
  - --use-case-directory
  - valueFrom: "$(inputs.use_case_directory.path)"
  - --sentinel-list
  - valueFrom: "$(inputs.sentinel_list.path)"
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
    sentinel_list:
      type: File
      doc: .txt file containing sentinel data paths (output from application package 1) - sentinel_paths.txt
      s:name: Sentinel list file
      s:description: Text file containing sentinel data paths (output from application package 1) - sentinel_paths.txt
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
      outputBinding:
        glob: $(inputs.use_case_directory.path)
    db_list:
      type: File
      outputBinding:
        glob: $(inputs.use_case_directory.path)/intermediate_dir/db_paths.txt

  requirements:
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)
          entry: $(inputs.use_case_directory)
          writable: true
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/iliad/iliad_oil_spill_pilot/oilspill002:1.0.0
    - class: NetworkAccess
      networkAccess: true
    - class: InlineJavascriptRequirement

  s:name: Sentinel-1 Oil Spill Detection Pipeline Preprocessing Tool
  s:description: Pre-processing of SAR images from Sentinel-1
  s:keywords:
    - oil spill
    - SAR
    - Sentinel-1
    - snappy
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
  
- class: CommandLineTool
  
  id: object_detection_tool
  
  baseCommand:
    - /srv/miniconda3/envs/oilspill003/bin/python
    - -m
    - oilspill003.main

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
        outputBinding:
          glob: $(inputs.use_case_directory.path)
    png_output_path:
      type: File
      outputBinding:
        glob: $(inputs.use_case_directory.path)/intermediate_dir/png_paths.txt
    csv_output_path:
      type: File
      outputBinding:
        glob: $(inputs.use_case_directory.path)/intermediate_dir/csv_paths.txt

  requirements:
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)
          entry: $(inputs.use_case_directory)
          writable: true
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



- class: CommandLineTool
  
  id: segmentation_tool

  baseCommand:
    - /srv/miniconda3/envs/oilspill004/bin/python
    - -m
    - oilspill004.main
  
  arguments:
  - --use-case-directory
  - valueFrom: "$(inputs.use_case_directory.path)"
  - --sentinel-list
  - valueFrom: "$(inputs.sentinel_list.path)"
  - --png-output-path
  - valueFrom: "$(inputs.png_output_path.path)"
  - --csv-output-path
  - valueFrom: "$(inputs.csv_output_path.path)"
  - valueFrom: |
      ${ return inputs.delete ? '--delete' : ''; }
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
    sentinel_list:
      type: File
      doc: .txt file containing sentinel data paths (output from application package 1) - sentinel_paths.txt
      s:name: Sentinel list file
      s:description: Text file containing sentinel data paths (output from application package 1) - sentinel_paths.txt
    png_output_path:
      type: File
      doc: .txt file containing png data paths (output from application package 3) - png_paths.txt
      s:name: Png list file
      s:description: Text file containing sentinel data paths (output from application package 3) - png_paths.txt
    csv_output_path:
      type: File
      doc: .txt file containing csv data paths (output from application package 3) - csv_paths.txt
      s:name: Csv list file
      s:description: Text file containing sentinel data paths (output from application package 3) - csv_paths.txt
    delete:
      type: boolean?
      doc: Enable deletion of generated auxiliary files
      s:name:
      s:description: Enable deletion of generated auxiliary files
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
      outputBinding:
        glob: $(inputs.use_case_directory.path)

  requirements:
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)
          entry: $(inputs.use_case_directory)
          writable: true
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/iliad/iliad_oil_spill_pilot/oilspill004:2.0.0
    - class: NetworkAccess
      networkAccess: true
    - class: InlineJavascriptRequirement

  s:name: Sentinel-1 Oil Spill Detection and Segmentation Pipeline 
  s:description: Deep learning model for detection and segmentation oil spills in Sentinel-1 SAR images.
  s:keywords:
    - oil spill
    - SAR
    - Sentinel-1
    - deep learning
    - segmentation
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
  




