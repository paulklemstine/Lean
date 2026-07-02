import json

with open('.aether_workspace/inflight_jobs.json') as f:
    jobs = json.load(f)

print(f"Total jobs in inflight: {len(jobs)}")
for job_id, job in list(jobs.items())[-10:]:
    print(f"Job ID: {job_id}")
    print(f"Status: {job.get('status')}")
    print(f"Phase: {job.get('phase', '')}")
    summary = job.get('result_summary', '')
    if summary:
        print("Summary excerpt:")
        print(summary[:300] + "...")
    else:
        print("No summary available.")
    
    # Check for discussion or thinking logs
    discussion = job.get('result_discussion', '')
    if discussion:
        print("Discussion excerpt:")
        print(discussion[:300] + "...")
    print("-" * 40)
