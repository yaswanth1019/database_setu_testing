import os

bronze_dir = r"d:\SETU_2\schema_new\bronze\Tables"
etl_dir = r"d:\SETU_2\schema_new\etl\Tables"

if not os.path.exists(etl_dir):
    os.makedirs(etl_dir)

for filename in os.listdir(bronze_dir):
    if filename.startswith("raw_") and filename.endswith(".sql"):
        with open(os.path.join(bronze_dir, filename), 'r') as f:
            content = f.read()
        
        etl_filename = filename.replace("raw_", "stg_")
        
        # Split into blocks based on "--" comments
        parts = content.split("--")
        
        new_content = "--\n"
        
        for part in parts:
            if "CREATE TABLE" in part:
                # Handle Table Definition Block
                lines = part.splitlines()
                transformed_lines = []
                for line in lines:
                    # Specific replacement for the table creation line
                    if "CREATE TABLE bronze.raw_" in line:
                        line = line.replace("CREATE TABLE bronze.raw_", "CREATE UNLOGGED TABLE etl.stg_")
                    
                    # Metadata tracing: Replace the Bronze ID with raw_id
                    if "id BIGINT GENERATED ALWAYS AS IDENTITY" in line:
                        line = line.replace("id BIGINT GENERATED ALWAYS AS IDENTITY", "raw_id BIGINT")
                    
                    # Remove system metadata
                    if "ingested_at" in line or "kafka_offset" in line:
                        continue
                        
                    # Catch-all for any missed raw_ to stg_ in this block EXCEPT for raw_id
                    temp_line = line.replace("raw_id", "RAW_ID_PLACEHOLDER")
                    temp_line = temp_line.replace("raw_", "stg_").replace("Schema: bronze", "Schema: etl")
                    line = temp_line.replace("RAW_ID_PLACEHOLDER", "raw_id")
                    
                    transformed_lines.append(line)
                
                new_content += "\n".join(transformed_lines) + "\n"
                break # Stop at the first (main) table definition block
        
        new_content += "\n--\n-- PostgreSQL database dump complete\n--\n"
        
        # Final cleanup for table name in parentheses if any
        new_content = new_content.replace("(raw_", "(stg_")
        
        with open(os.path.join(etl_dir, etl_filename), 'w') as f:
            f.write(new_content)

print("ETL tables re-generated successfully with UNLOGGED status and raw_id column.")
