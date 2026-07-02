import json
import asyncio
import os

try:
    with open(".env") as f:
        for line in f:
            if line.startswith("ARISTOTLE_API_KEY"):
                key = line.split("=", 1)[1].strip().strip('"').strip("'")
                os.environ["ARISTOTLE_API_KEY"] = key
                break
except Exception as e:
    print(f"Could not load .env: {e}")

try:
    import aristotlelib
except ImportError:
    print("aristotlelib not found!")
    exit(1)

async def main():
    jobs = json.load(open('.aether_workspace/inflight_jobs.json'))
    count = 0
    
    recent_jobs = list(jobs.values())[-15:]
    recent_jobs.reverse()
    
    for job in recent_jobs:
        if count >= 10:
            break
        project_id = job.get('project_id')
        if not project_id:
            continue
            
        print(f"============================================================")
        print(f"Project ID: {project_id} (Status: {job.get('status')})")
        print(f"Job Concept: {job.get('concept', {}).get('title', 'Unknown')}")
        count += 1
        
        try:
            project = await aristotlelib.Project.from_id(project_id)
            tasks, _ = await project.get_tasks()
            
            traces = []
            for task in tasks:
                events, _ = await task.get_events(limit=100, newest_first=False)
                for e in events:
                    if e.event_type.name == "THINKING":
                        trace_text = e.explanation or e.content
                        if trace_text:
                            traces.append(trace_text)
            
            print(f"Found {len(traces)} THINKING logs.")
            if traces:
                print("--- LATEST THINKING LOG ---")
                # Print the last 1500 chars of the last log
                text = traces[-1]
                print(text[-1500:])
            else:
                print("No THINKING logs found. Here are the events:")
                for task in tasks:
                    events, _ = await task.get_events(limit=10, newest_first=False)
                    for e in events:
                        print(f"  - {e.event_type.name}: {e.explanation or e.content}")
        except Exception as e:
            print(f"Error fetching logs for {project_id}: {e}")

asyncio.run(main())
