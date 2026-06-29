import asyncio
import os
from pathlib import Path
from pi_agent_client import ResearchConcept
from knowledge_extractor import KnowledgeExtractor, ResearchJob

async def main():
    job = ResearchJob(
        job_id="test_job_final",
        cycle_n=1,
        concept=ResearchConcept(
            domain="Tropical",
            title="Test integration",
            concept_description="Test",
            mathematical_framing="Test",
            research_mode="prove",
        ),
        prompt="Test prompt"
    )
    job.quality_score = 0.9
    job.result_summary = "Aristotle modified Tropical/Test.lean and Tropical/Cleanup.lean"
    
    # Let's provide a simple mock of what _parse_aristotle_result generates
    job.result_lean = """-- NEW_FILE: Tropical/Test.lean
import Mathlib

def my_test := 1

-- NEW_FILE: Tropical/Cleanup.lean
import Mathlib

def duplicate_test := 1
"""
    
    print("Initializing KnowledgeExtractor...")
    ke = KnowledgeExtractor("/home/raver1975/lean/Aether/config.yaml")
    
    print("Running integrate_async...")
    # This will invoke pi-coding-agent with the combined prompt
    job = await ke.integrate_async(job)
    print(f"Job status: {job.status}")
    
    # Verify cleanup occurred
    test_lean = Path("/home/raver1975/lean/Catalog/Tropical/Test.lean")
    if test_lean.exists():
        print("Success! File was created.")
    else:
        print("Failed! File was not created.")

if __name__ == "__main__":
    asyncio.run(main())
