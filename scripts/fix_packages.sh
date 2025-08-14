#!/bin/bash
set -euo pipefail

# Process both main and test sources
SRC_DIRS=(
  "src/main/java/com/ashu/problemsolving"
  "src/test/java/com/ashu/problemsolving"
)

# Old → new folder names (Java-safe)
declare -A RENAME_MAP=(
  ["01-java-basics-and-syntax"]="java_basics_and_syntax_01"
  ["02-data-types-and-variables"]="data_types_and_variables_02"
  ["03-operators-and-expressions"]="operators_and_expressions_03"
  ["04-control-flow-statements"]="control_flow_statements_04"
  ["05-methods-and-parameters"]="methods_and_parameters_05"
  ["06-classes-and-objects"]="classes_and_objects_06"
  ["07-constructors-and-initialization-blocks"]="constructors_and_initialization_blocks_07"
  ["08-static-and-final-keywords"]="static_and_final_keywords_08"
  ["09-access-modifiers-and-encapsulation"]="access_modifiers_and_encapsulation_09"
  ["10-inheritance-and-method-overriding"]="inheritance_and_method_overriding_10"
  ["11-polymorphism"]="polymorphism_11"
  ["12-abstraction-and-interfaces"]="abstraction_and_interfaces_12"
  ["13-nested-and-inner-classes"]="nested_and_inner_classes_13"
  ["14-packages-and-imports"]="packages_and_imports_14"
  ["15-strings-and-stringbuilder"]="strings_and_stringbuilder_15"
  ["16-arrays-and-multidimensional-arrays"]="arrays_and_multidimensional_arrays_16"
  ["17-enums"]="enums_17"
  ["18-wrapper-classes-and-autoboxing"]="wrapper_classes_and_autoboxing_18"
  ["19-exception-handling"]="exception_handling_19"
  ["20-java-collections-framework"]="java_collections_framework_20"
  ["21-generics"]="generics_21"
  ["22-lambda-expressions-and-functional-interfaces"]="lambda_expressions_and_functional_interfaces_22"
  ["23-streams-api"]="streams_api_23"
  ["24-date-and-time-api"]="date_and_time_api_24"
  ["25-annotations"]="annotations_25"
  ["26-reflection-api"]="reflection_api_26"
  ["27-serialization-and-deserialization"]="serialization_and_deserialization_27"
  ["28-multithreading"]="multithreading_28"
  ["29-concurrency-api"]="concurrency_api_29"
  ["30-memory-management-and-garbage-collection"]="memory_management_and_garbage_collection_30"
  ["31-java-math-api"]="java_math_api_31"
  ["32-java-internationalization"]="java_internationalization_32"
  ["33-java-properties-and-resource-bundles"]="java_properties_and_resource_bundles_33"
  ["34-java-networking"]="java_networking_34"
  ["35-java-process-api"]="java_process_api_35"
  ["36-java-nio"]="java_nio_36"
  ["37-java-modules"]="java_modules_37"
  ["38-java-security-api"]="java_security_api_38"
  ["39-java-service-loader"]="java_service_loader_39"
  ["40-jvm-internals"]="jvm_internals_40"
)

rename_folders() {
  local base="$1"
  [ -d "$base" ] || return 0
  echo "==> Renaming under: $base"
  for old in "${!RENAME_MAP[@]}"; do
    local new="${RENAME_MAP[$old]}"
    if [ -d "$base/$old" ]; then
      echo "   - $old → $new"
      mv "$base/$old" "$base/$new"
    fi
  done
}

fix_package_lines() {
  local base="$1"
  [ -d "$base" ] || return 0
  echo "==> Fixing package lines under: $base"
  # For every .java file, compute desired package and update/insert
  find "$base" -type f -name "*.java" | while read -r file; do
    # path after '.../com/ashu/problemsolving/'
    local rel="${file#$base/}"
    local dir_rel
    dir_rel=$(dirname "$rel")
    # Build package: com.ashu.problemsolving + '.' + dir_rel with slashes replaced by dots (if not '.')
    local pkg="com.ashu.problemsolving"
    if [ "$dir_rel" != "." ]; then
      pkg="${pkg}.$(echo "$dir_rel" | tr '/' '.')"
    fi

    if grep -qE '^[[:space:]]*package[[:space:]]+' "$file"; then
      # Replace existing package line
      sed -i "1,/^[[:space:]]*package[[:space:]]\+.*;/s#^[[:space:]]*package[[:space:]]\+.*;#package ${pkg};#" "$file"
    else
      # Prepend package line (keeps it simple & valid)
      tmp="${file}.tmp"
      {
        echo "package ${pkg};"
        echo
        cat "$file"
      } > "$tmp"
      mv "$tmp" "$file"
    fi
  done
}

main() {
  for base in "${SRC_DIRS[@]}"; do
    rename_folders "$base"
  done
  for base in "${SRC_DIRS[@]}"; do
    fix_package_lines "$base"
  done
  echo "✅ Done: folders normalized and package declarations fixed."
}

main
