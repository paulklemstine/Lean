import asyncio
from pathlib import Path
from pi_agent_client import ResearchConcept
from knowledge_extractor import KnowledgeExtractor, ResearchJob

async def main():
    job = ResearchJob(
        job_id="test_job_123",
        cycle_n=1,
        concept=ResearchConcept(
            domain="Tropical",
            title="Test integration",
            concept_description="Test",
            mathematical_framing="Test",
            research_mode="prove",
            novelty_estimate=0.5,
            breakthrough_potential=0.5,
            key_references=[],
            lean_guess="",
            catalog_references=[]
        ),
        prompt="Test prompt"
    )
    job.quality_score = 0.9
    job.result_summary = "Aristotle modified Tropical/Test.lean"
    job.result_lean = "-- NEW_FILE: Tropical/Test.lean\nimport Mathlib\n\ndef my_test := 1"
    
    print("Initializing KnowledgeExtractor...")
    ke = KnowledgeExtractor("/home/raver1975/lean/Aether/config.yaml")
    
    print("Running integrate_async...")
    job = await ke.integrate_async(job)
    print(f"Job status: {job.status}")

if __name__ == "__main__":
    asyncio.run(main())
