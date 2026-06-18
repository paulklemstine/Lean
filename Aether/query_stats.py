import sqlite3
import json
import sys
import time
from collections import defaultdict

db_path = "/home/raver1975/lean/Aether/.aether_workspace/archive_db/catalog.sqlite"
out_path = "/home/raver1975/lean/Aether/query_output.txt"

def log(msg):
    with open(out_path, "a", encoding="utf-8") as f:
        f.write(msg + "\n")
    print(msg)

def run_simple_query(conn, label, sql):
    t0 = time.time()
    log(f"=== {label} ===")
    cursor = conn.cursor()
    cursor.execute(sql)
    cols = [col[0] for col in cursor.description]
    rows = cursor.fetchall()
    
    col_width = 25
    header = " | ".join(f"{col:<{col_width}}" for col in cols)
    log(header)
    log("-" * len(header))
    
    for row in rows:
        row_str = " | ".join(f"{str(val):<{col_width}}" for val in row)
        log(row_str)
    
    log(f"Completed in {time.time() - t0:.2f}s\n")

def main():
    # Clear output file
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("Aether Backfill Analysis Results\n")
        f.write("===============================\n\n")

    log(f"Connecting to database at {db_path}...")
    try:
        conn = sqlite3.connect(db_path)
        conn.row_factory = sqlite3.Row
    except Exception as e:
        log(f"Error connecting to database: {e}")
        sys.exit(1)

    # 1. Simple Counts
    run_simple_query(conn, "Table Counts", """
        SELECT 
            (SELECT COUNT(*) FROM projects) as total_projects,
            (SELECT COUNT(*) FROM files) as unique_files,
            (SELECT COUNT(*) FROM project_files) as total_project_file_mappings,
            (SELECT COUNT(*) FROM theorems) as total_theorems,
            (SELECT COUNT(*) FROM prompts) as total_prompts,
            (SELECT COUNT(*) FROM packages) as total_packages
    """)

    # 2. Python-based streaming aggregation for inputs and outputs (16M rows)
    log("=== Stream-processing project_files and files (Hybrid Query) ===")
    t_start = time.time()

    # Load file sizes
    log("Loading file sizes from 'files' table...")
    cursor = conn.cursor()
    cursor.execute("SELECT hash, size FROM files")
    file_sizes = {r[0]: r[1] for r in cursor.fetchall()}
    log(f"Loaded {len(file_sizes)} unique files in {time.time() - t_start:.2f}s.")

    t_stream = time.time()
    cursor.execute("SELECT role, file_hash, project_id FROM project_files")

    input_size = 0
    output_size = 0
    input_count = 0
    output_count = 0
    unique_inputs = set()
    unique_outputs = set()

    project_stats = defaultdict(lambda: {'input_count': 0, 'output_count': 0, 'input_size': 0, 'output_size': 0})

    chunk_size = 500000
    processed = 0
    while True:
        rows = cursor.fetchmany(chunk_size)
        if not rows:
            break
        for role, file_hash, project_id in rows:
            sz = file_sizes.get(file_hash, 0)
            p = project_stats[project_id]
            if role == 'input':
                input_size += sz
                input_count += 1
                unique_inputs.add(file_hash)
                p['input_count'] += 1
                p['input_size'] += sz
            else:
                output_size += sz
                output_count += 1
                unique_outputs.add(file_hash)
                p['output_count'] += 1
                p['output_size'] += sz
        processed += len(rows)
        log(f"Processed {processed} mappings in {time.time() - t_stream:.2f}s...")

    log(f"Streaming completed. Total processed: {processed} in {time.time() - t_stream:.2f}s.")

    # 3. Analyze and print the processed statistics
    log("\n=== Input vs Output Mapping and Size Metrics ===")
    log(f"{'Role':<10} | {'Mapping Count':<15} | {'Unique Files':<15} | {'Uncompressed Size (MB)':<25}")
    log("-" * 75)
    log(f"{'input':<10} | {input_count:<15} | {len(unique_inputs):<15} | {input_size / (1024*1024):.2f}")
    log(f"{'output':<10} | {output_count:<15} | {len(unique_outputs):<15} | {output_size / (1024*1024):.2f}")

    # 4. Deduplication stats
    cas_bytes = sum(file_sizes.values())
    raw_bytes = input_size + output_size
    dedup_ratio = raw_bytes / cas_bytes if cas_bytes > 0 else 1.0
    saved_bytes = raw_bytes - cas_bytes

    log("\n=== Storage Deduplication Analysis ===")
    log(f"{'Metric':<30} | {'Value':<15}")
    log("-" * 50)
    log(f"{'Raw Size (GB)':<30} | {raw_bytes / (1024*1024*1024):.2f}")
    log(f"{'CAS Size (GB)':<30} | {cas_bytes / (1024*1024*1024):.2f}")
    log(f"{'Deduplication Ratio':<30} | {dedup_ratio:.2f}x")
    log(f"{'Storage Saved (GB)':<30} | {saved_bytes / (1024*1024*1024):.2f}")

    # 5. Per-Project distributions
    if project_stats:
        log("\n=== Per-Project File & Size Distribution (Stats) ===")
        log(f"{'Metric':<30} | {'Input':<15} | {'Output':<15}")
        log("-" * 66)
        
        in_counts = [p['input_count'] for p in project_stats.values()]
        out_counts = [p['output_count'] for p in project_stats.values()]
        in_sizes_mb = [p['input_size'] / (1024*1024) for p in project_stats.values()]
        out_sizes_mb = [p['output_size'] / (1024*1024) for p in project_stats.values()]
        
        log(f"{'Average File Count':<30} | {sum(in_counts)/len(in_counts):.2f} | {sum(out_counts)/len(out_counts):.2f}")
        log(f"{'Max File Count':<30} | {max(in_counts)} | {max(out_counts)}")
        log(f"{'Min File Count':<30} | {min(in_counts)} | {min(out_counts)}")
        log(f"{'Average Size (MB)':<30} | {sum(in_sizes_mb)/len(in_sizes_mb):.2f} | {sum(out_sizes_mb)/len(out_sizes_mb):.2f}")
        log(f"{'Max Size (MB)':<30} | {max(in_sizes_mb):.2f} | {max(out_sizes_mb):.2f}")
    
    log("\n")

    # 6. Theorem Completeness & Sorry Stats
    run_simple_query(conn, "Theorem Completion and sorry/uses_sorry Stats", """
        SELECT 
            COUNT(*) as total_theorems,
            SUM(is_sorry) as sorry_count,
            SUM(uses_sorry) as uses_sorry_count,
            SUM(is_complete) as complete_count,
            ROUND(AVG(is_complete) * 100, 2) as completeness_percentage
        FROM theorems
    """)

    # 7. Projects status
    run_simple_query(conn, "Projects Status Summary", """
        SELECT 
            status,
            COUNT(*) as project_count
        FROM projects
        GROUP BY status
        ORDER BY project_count DESC
    """)

    # 8. Domains
    run_simple_query(conn, "Top 15 Domains by Package Count", """
        SELECT 
            domain,
            COUNT(*) as package_count
        FROM packages
        GROUP BY domain
        ORDER BY package_count DESC
        LIMIT 15
    """)

    conn.close()
    log("All queries and analysis completed successfully.")

if __name__ == '__main__':
    main()
