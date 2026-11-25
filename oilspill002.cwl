cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- baseCommand:
    - /srv/miniconda3/envs/oilspill002/bin/python
    - -m
    - oilspill002.main
  class: CommandLineTool

  id: preprocessing_tool

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
      doc: Directory containing the results
      outputBinding:
        glob: "$(inputs.use_case_directory.path)"
      s:name: Results Directory
      s:description: The directory containing the outputs of the pre-processing.

  requirements:
    - class: InlineJavascriptRequirement
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)
          writable: true
          entry: $(inputs.use_case_directory)
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/iliad/iliad_oil_spill_pilot/oilspill002:1.0.0
    - class: NetworkAccess
      networkAccess: true

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
