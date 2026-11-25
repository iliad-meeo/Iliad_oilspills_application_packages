cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- baseCommand:
    - /srv/miniconda3/envs/oilspill001/bin/python
    - -m
    - oilspill001.main
  class: CommandLineTool

  id: datasearch_tool

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
      doc: Directory containing the search results
      outputBinding:
        glob: "$(inputs.use_case_directory)"
      s:name: Results Directory
      s:description: The directory containing the outputs of the data search.
      

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
