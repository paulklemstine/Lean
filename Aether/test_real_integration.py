import asyncio
from pathlib import Path
from pi_agent_client import ResearchConcept
from knowledge_extractor import KnowledgeExtractor, ResearchJob

async def main():
    job = ResearchJob(
        job_id="eb63cc36",
        cycle_n=1,
        concept=ResearchConcept(
            domain="Pythagorean",
            title="Test real integration",
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
    
    print("Initializing KnowledgeExtractor...")
    ke = KnowledgeExtractor("/home/raver1975/lean/Aether/config.yaml")
    
    extract_dir = Path("/home/raver1975/lean/Aether/.aether_workspace/projects/eb63cc36")
    print("Parsing Aristotle result...")
    job = ke._parse_aristotle_result(job, extract_dir)
    print(f"Parsed {len(job.result_lean) if job.result_lean else 0} bytes of Lean results.")
    
    print("Running integrate_async...")
    job = await ke.integrate_async(job)
    print(f"Job status: {job.status}")

if __name__ == "__main__":
    asyncio.run(main())
