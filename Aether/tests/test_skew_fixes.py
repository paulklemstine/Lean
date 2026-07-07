import json
from pathlib import Path
from unittest.mock import MagicMock
import pytest

from aristotle_loop import UCBSelector, DomainStats, DOMAINS
from output_organizer import normalize_domain
from knowledge_extractor import KnowledgeExtractor, ResearchJob

def test_ucb_penalties():
    # 1. Recency Penalty Test
    selector = UCBSelector(exploration_constant=1.5)
    
    # Pre-populate some stats
    for d in DOMAINS:
        selector.domain_stats[d] = DomainStats(n_selections=10, total_reward=8.0)
        selector.domain_stats[d].rewards = [0.8] * 10
    selector.total_selections = 10 * len(DOMAINS)
    
    # Select Algebra at step total_selections (which is 170)
    selector.update("Algebra", "prove", 1.0)
    
    # Immediately after, check score of Algebra
    score_with_recency = selector._ucb_score("Algebra")
    
    # Clear the last selected index to simulate no recent selection
    selector.domain_stats["Algebra"].last_selected_index = 0
    score_no_recency = selector._ucb_score("Algebra")
    
    assert score_with_recency < score_no_recency
    
    # 2. Frequency Penalty Test
    selector_freq = UCBSelector(exploration_constant=1.5)
    for d in DOMAINS:
        selector_freq.domain_stats[d] = DomainStats(n_selections=2, total_reward=1.6)
        selector_freq.domain_stats[d].rewards = [0.8, 0.8]
    selector_freq.total_selections = 2 * len(DOMAINS)
    
    # Inflate Algebra selections to make its share > 1.5x of fair share (1/17)
    selector_freq.domain_stats["Algebra"].n_selections = 10
    selector_freq.total_selections = 34 + 8
    
    # Algebra share is 10/42 = ~0.238, which is > 1.5 * (1/17) = ~0.088
    score_with_freq = selector_freq._ucb_score("Algebra")
    
    # Reset selections to a low number
    selector_freq.domain_stats["Algebra"].n_selections = 2
    score_no_freq = selector_freq._ucb_score("Algebra")
    
    assert score_with_freq < score_no_freq

def test_domain_auto_alignment(tmp_path):
    # Mocking knowledge extractor and job
    config = {
        "catalog": {"root_dir": str(tmp_path / "Catalog")},
        "workspace": str(tmp_path / "workspace")
    }
    extractor = KnowledgeExtractor(config=config)
    job = MagicMock()
    job.concept.title = "Test Theorem"
    job.concept.domain = "Novelty"
    job.result_demo = ""
    job.result_algorithms = ""
    job.result_article = ""
    job.result_research_paper = ""
    job.result_future_directions = ""
    job.result_lean = ""
    job.result_paper = ""
    job.job_id = "test_job"
    job.source_exp_ids = []
    job.integrated_paths = []
    
    # Package JSON string with a wrong domain
    pkg_json = json.dumps({
        "title": "Test Proof",
        "domain": "Novelty",
        "lean_proofs": [
            {
                "file": "Catalog/Bridges/EmergentBridge.lean",
                "name": "EmergentBridge.lean",
                "code": "theorem foo : true := by trivial"
            }
        ]
    })
    
    enriched = extractor._enrich_json_package(pkg_json, job)
    enriched_data = json.loads(enriched)
    
    # Should be auto-aligned to Bridges
    assert enriched_data["domain"] == "Bridges"

@pytest.mark.skip(reason="In-place package merging disabled — once published, it is canon")
def test_in_place_package_merging(tmp_path):
    # Set up Package directories
    pkg_dir = tmp_path / "Packages"
    pkg_dir.mkdir(parents=True)
    # catalog_root must exist so KnowledgeExtractor does not fall back to the real Catalog
    (tmp_path / "Catalog").mkdir(parents=True, exist_ok=True)
    
    # Pre-existing parent package
    parent_pkg = {
        "title": "Existential Theorem",
        "domain": "Algebra",
        "lean_files": ["Catalog/Algebra/Parent.lean"],
        "lean_proofs": [
            {"file": "Catalog/Algebra/Parent.lean", "code": "def old := 1", "theorems": 1}
        ],
        "key_results": ["Old result"],
        "keywords": ["old"]
    }
    parent_file = pkg_dir / "existential_theorem.json"
    parent_file.write_text(json.dumps(parent_pkg, indent=2))
    
    # Create KnowledgeExtractor and job
    config = {
        "catalog": {"root_dir": str(tmp_path / "Catalog")},
        "workspace": str(tmp_path / "workspace")
    }
    extractor = KnowledgeExtractor(config=config)
    from unittest.mock import AsyncMock
    extractor._review_file_batch = AsyncMock(return_value={"Catalog/Algebra/Parent.lean": "Algebra/Parent.lean"})
    
    job = MagicMock()
    job.job_id = "test_job_id"
    job.concept.research_mode = "sorry_fill"
    job.concept.title = "Existential Theorem"
    job.concept.domain = "Algebra"
    job.quality_score = 0.8
    # Need to simulate that the output lists the filename we are looking for
    job.result_lean = "-- NEW_FILE: Catalog/Algebra/Parent.lean\ndef old := 1\ndef new := 2\ntheorem new_thm : true := by trivial"
    job.result_json_package = json.dumps({
        "title": "Close Proofs for Existential Theorem",
        "domain": "Algebra",
        "lean_files": ["Catalog/Algebra/Parent.lean"],
        "lean_proofs": [
            {"file": "Catalog/Algebra/Parent.lean", "code": "def old := 1\ndef new := 2\ntheorem new_thm : true := by trivial", "theorems": 2}
        ],
        "key_results": ["New result"],
        "keywords": ["new"]
    })
    job.result_discussion = ""
    job.result_demo = ""
    job.result_algorithms = ""
    job.result_article = ""
    job.result_research_paper = ""
    job.result_future_directions = ""
    job.result_paper = ""
    job.source_exp_ids = []
    job.integrated_paths = []
    
    # Run integration
    import asyncio
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    
    # Run the integration
    loop.run_until_complete(extractor.integrate_async(job))
    
    # Check that parent file has been updated and no new file was created
    all_packages = list(pkg_dir.glob("*.json"))
    assert len(all_packages) == 1
    assert all_packages[0].name == "existential_theorem.json"
    
    updated_content = json.loads(all_packages[0].read_text(encoding="utf-8"))
    assert "New result" in updated_content["key_results"]
    assert "Old result" in updated_content["key_results"]
    assert "new" in updated_content["keywords"]
    assert "old" in updated_content["keywords"]
    
    # Verify lean proofs merged/updated
    proofs = updated_content["lean_proofs"]
    assert len(proofs) == 1
    assert proofs[0]["theorems"] == 2
