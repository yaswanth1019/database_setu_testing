import os

# Configuration: Retrieved from environment variables with local fallbacks for development
BRONZE_DIR = os.getenv("BRONZE_DIR", r"d:\SETU_2\schema_new\bronze\Tables")
ETL_DIR = os.getenv("ETL_DIR", r"d:\SETU_2\schema_new\etl\Tables")

def generate_etl_tables():
    """
    Transforms Bronze (Raw) table definitions into ETL (Staging) UNLOGGED tables.
    Uses environment variables for directory paths.
    """
    if not os.path.exists(ETL_DIR):
        os.makedirs(ETL_DIR)
        print(f"Created directory: {ETL_DIR}")

    if not os.path.exists(BRONZE_DIR):
        print(f"Error: Bronze directory not found at {BRONZE_DIR}")
        return

    for filename in os.listdir(BRONZE_DIR):
        if filename.startswith("raw_") and filename.endswith(".sql"):
            with open(os.path.join(BRONZE_DIR, filename), 'r') as f:
                content = f.read()
            
            etl_filename = filename.replace("raw_", "stg_")
            
            # Split into blocks based on "--" comments to isolate the CREATE TABLE block
            parts = content.split("--")
            new_content = "--\n"
            
            for part in parts:
                if "CREATE TABLE" in part:
                    lines = part.splitlines()
                    transformed_lines = []
                    for line in lines:
                        # 1. Transform CREATE TABLE to CREATE UNLOGGED TABLE and switch schema
                        if "CREATE TABLE bronze.raw_" in line:
                            line = line.replace("CREATE TABLE bronze.raw_", "CREATE UNLOGGED TABLE etl.stg_")
                        
                        # 2. Map Bronze ID to raw_id for traceability
                        if "id BIGINT GENERATED ALWAYS AS IDENTITY" in line:
                            line = line.replace("id BIGINT GENERATED ALWAYS AS IDENTITY", "raw_id BIGINT")
                        
                        # 3. Strip system metadata (Partitioning/Kafka info not needed in Staging)
                        if "ingested_at" in line or "kafka_offset" in line:
                            continue
                            
                        # 4. Catch-all for any missed raw_ to stg_ in this block EXCEPT for raw_id
                        temp_line = line.replace("raw_id", "RAW_ID_PLACEHOLDER")
                        temp_line = temp_line.replace("raw_", "stg_").replace("Schema: bronze", "Schema: etl")
                        line = temp_line.replace("RAW_ID_PLACEHOLDER", "raw_id")
                        
                        transformed_lines.append(line)
                    
                    new_content += "\n".join(transformed_lines) + "\n"
                    break # Stop at the first (main) table definition block
            
            new_content += "\n--\n-- PostgreSQL database dump complete\n--\n"
            
            # Final cleanup for table name in parentheses if any
            new_content = new_content.replace("(raw_", "(stg_")
            
            output_path = os.path.join(ETL_DIR, etl_filename)
            with open(output_path, 'w') as f:
                f.write(new_content)
            print(f"Generated: {etl_filename}")

if __name__ == "__main__":
    generate_etl_tables()
    print("\nETL tables re-generated successfully with UNLOGGED status and raw_id column.")
