#!/usr/bin/env python3
"""Interactive tool to query arXiv and mine research directions."""

import argparse
import sys
import time
from pathlib import Path
from typing import List, Optional

# Set up paths to import Aether packages
tools_dir = Path(__file__).resolve().parent
repo_root = tools_dir.parent
aether_dir = repo_root / "Aether"
if str(aether_dir) not in sys.path:
    sys.path.insert(0, str(aether_dir))

from arxiv_provider import ArxivTexProvider, ArxivPaper
from arxiv_miner import ArxivMiner
from pi_agent_client import PiAgentClient
from catalog_analyzer import CatalogAnalyzer
from research_memory import FutureDirectionsManager, FutureDirection, ResearchMemory


def get_active_keywords(workspace: Path) -> List[str]:
    """Get active keywords from the recent successful experiments in research memory."""
    try:
        exp_mem = ResearchMemory(workspace)
        # Get 5 most recent successful experiments
        successes = [r for r in exp_mem._cache if r.status == "success"][-5:]
        if not successes:
            return []
        
        keywords = set()
        stop_words = {
            "the", "a", "an", "and", "or", "but", "if", "then", "of", "to", "in", "on", 
            "with", "for", "by", "about", "against", "between", "into", "through", 
            "during", "before", "after", "above", "below", "from", "up", "down", 
            "in", "out", "over", "under", "again", "further", "then", "once", "here", 
            "there", "when", "where", "why", "how", "all", "any", "both", "each", 
            "few", "more", "most", "other", "some", "such", "no", "nor", "not", 
            "only", "own", "same", "so", "than", "too", "very", "s", "t", "can", 
            "will", "just", "don", "should", "now", "proved", "theorem", "lemma", 
            "proof", "theory", "formal", "formalization", "lean", "mathlib", "using",
            "class", "instance", "definition", "verify", "verification"
        }
        
        for r in successes:
            text = r.concept_title + " " + " ".join(r.key_theorems)
            import re
            words = re.findall(r'[a-zA-Z]{3,}', text.lower())
            for w in words:
                if w not in stop_words:
                    keywords.add(w)
        
        return list(keywords)[:10]
    except Exception as e:
        print(f"[Warning] Could not extract keywords from ResearchMemory: {e}")
        return []


def load_dotenv():
    """Load Aether/.env file into os.environ if present."""
    import os
    env_path = repo_root / "Aether" / ".env"
    if env_path.exists():
        try:
            for line in env_path.read_text().splitlines():
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    key = key.strip()
                    val = val.strip().strip("\"'")
                    if key and val and key not in os.environ:
                        os.environ[key] = val
        except Exception as e:
            print(f"[Warning] Failed to load .env: {e}")


def main():
    load_dotenv()
    parser = argparse.ArgumentParser(description="Query arXiv and mine research directions.")
    parser.add_argument("--query", type=str, help="Search query (e.g. 'cat:math.NT' or keywords). If not provided, will prompt.")
    parser.add_argument("--limit", type=int, default=5, help="Number of papers to retrieve for metadata preview (default: 5)")
    parser.add_argument("--domain", type=str, default="", help="Aether domain (e.g. Tropical, Pythagorean) to target query.")
    parser.add_argument("--workspace", type=str, default=str(repo_root / "workspace"), help="Workspace directory.")
    parser.add_argument("--select", type=int, default=0, help="1-indexed paper choice to run non-interactively.")
    args = parser.parse_args()

    workspace_path = Path(args.workspace).resolve()
    catalog_root = repo_root / "Catalog"

    print("=" * 60)
    print(" ARXIV INTERACTIVE SEARCH & MINER")
    print("=" * 60)
    print(f"Workspace: {workspace_path}")
    print(f"Catalog: {catalog_root}")

    # Set up provider
    provider = ArxivTexProvider(batch_size=args.limit)

    # Determine query
    query = args.query
    if not query:
        if args.domain:
            from arxiv_provider import DOMAIN_QUERIES
            query = DOMAIN_QUERIES.get(args.domain, "")
            if not query:
                print(f"[Error] Unknown domain: {args.domain}")
                sys.exit(1)
        else:
            print("No query provided. Select a base query or enter custom keywords:")
            print("1. Pythagorean (cat:math.NT)")
            print("2. Tropical (cat:math.CO or tropical)")
            print("3. Cryptography (cat:cs.CR or lattice-based)")
            print("4. Algebra (cat:math.RA or group theory)")
            print("5. MachineLearning (cat:cs.LG)")
            print("6. Enter custom search string")
            choice = input("Choice (1-6): ").strip()
            
            if choice == "1":
                query = "cat:math.NT"
            elif choice == "2":
                query = 'cat:math.CO OR all:"tropical"'
            elif choice == "3":
                query = 'cat:cs.CR OR all:"lattice-based"'
            elif choice == "4":
                query = "cat:math.RA"
            elif choice == "5":
                query = "cat:cs.LG"
            else:
                query = input("Enter query: ").strip()

    if not query:
        print("[Error] No query specified.")
        sys.exit(1)

    print(f"\nQuerying arXiv: {query}...")
    provider.set_query(query)
    
    # Fetch metadata (first batch)
    papers = provider._fetch_next_batch()
    if not papers:
        print("No papers found matching the query.")
        sys.exit(0)

    # Rank papers if we have active keywords
    keywords = get_active_keywords(workspace_path)
    if keywords:
        print(f"Active catalog keywords for relevance ranking: {', '.join(keywords)}")
        scored_papers = []
        for p in papers:
            score = provider._score_paper_relevance(p, keywords)
            scored_papers.append((score, p))
        scored_papers.sort(key=lambda x: x[0], reverse=True)
        papers = [p for _, p in scored_papers]

    # Present papers to the user
    print(f"\nFound {len(papers)} papers (showing top {args.limit}):")
    for i, paper in enumerate(papers[:args.limit]):
        print(f"\n[{i + 1}] {paper.title}")
        print(f"    Authors: {paper.authors}")
        print(f"    Categories: {paper.categories} | ID: {paper.paper_id}")
        print(f"    Abstract: {paper.abstract[:200]}...")

    # Let user select a paper
    if args.select > 0:
        idx = args.select - 1
        if 0 <= idx < min(len(papers), args.limit):
            selected_paper = papers[idx]
        else:
            print(f"[Error] Selected index {args.select} is out of bounds (1-{min(len(papers), args.limit)}).")
            sys.exit(1)
    else:
        while True:
            try:
                choice = input(f"\nSelect a paper to mine (1-{min(len(papers), args.limit)}) or 'q' to quit: ").strip()
                if choice.lower() == 'q':
                    print("Exiting.")
                    sys.exit(0)
                idx = int(choice) - 1
                if 0 <= idx < min(len(papers), args.limit):
                    selected_paper = papers[idx]
                    break
                else:
                    print("Invalid index.")
            except ValueError:
                print("Please enter a number.")

    print(f"\nDownloading and extracting LaTeX for: {selected_paper.title}...")
    tex = provider._download_and_extract_tex(selected_paper.paper_id)
    if not tex:
        print("[Error] Could not retrieve LaTeX source for this paper.")
        sys.exit(1)
    
    selected_paper.tex_content = tex
    print(f"Extracted {len(tex)} characters of LaTeX content.")

    print("\nInstantiating Pi-Agent and Catalog Analyzer...")
    import yaml
    config_path = repo_root / "Aether" / "config.yaml"
    config = yaml.safe_load(config_path.read_text(encoding="utf-8")) if config_path.exists() else {}
    pi_cfg = config.get("pi_agent", {})
    ollama_cloud_cfg = pi_cfg.get("ollama_cloud", {})
    ollama_cloud_cfg["enabled"] = True  # Force enable fallback

    pi_agent = PiAgentClient(
        memory=ResearchMemory(workspace_path),
        catalog_root=catalog_root,
        model=pi_cfg.get("model", "openai-large"),
        pollinations=pi_cfg.get("pollinations", {}),
        use_ollama=pi_cfg.get("use_ollama", False),
        ollama_base_url=pi_cfg.get("ollama_base_url"),
        ollama_model=pi_cfg.get("ollama_model"),
        ollama_cloud=ollama_cloud_cfg,
    )
    catalog_analyzer = CatalogAnalyzer(catalog_root)
    research_memory = FutureDirectionsManager(workspace_path)

    miner = ArxivMiner(
        pi_agent=pi_agent,
        catalog_analyzer=catalog_analyzer,
        research_memory=research_memory,
    )

    print("\nMining research direction...")
    # Build prompt context
    catalog_analyzer.scan()
    catalog_summary = catalog_analyzer.get_domain_summary_for_prompt()
    theorem_listing = catalog_analyzer.get_key_theorem_listing(max_per_domain=3, max_total=20)

    from arxiv_miner import _MINING_USER_PROMPT_TEMPLATE, _MINING_SYSTEM_PROMPT
    user_prompt = _MINING_USER_PROMPT_TEMPLATE.format(
        title=selected_paper.title[:200],
        arxiv_id=selected_paper.paper_id,
        authors=selected_paper.authors[:200],
        categories=selected_paper.categories[:100],
        paper_content=selected_paper.tex_content[:6000],
        catalog_summary=catalog_summary[:3000] if catalog_summary else "Catalog not available.",
        theorem_listing=theorem_listing[:2000] if theorem_listing else "No theorem listing available.",
    )

    try:
        print("[LLM Call] Sending paper content to Pi-Agent...")
        raw = pi_agent._call_ollama(
            _MINING_SYSTEM_PROMPT,
            user_prompt,
            timeout=120,
        )
        
        direction = miner._parse_direction_response(raw, selected_paper)
        if direction:
            research_memory.add_direction(direction)
            print("=" * 60)
            print(f"SUCCESSFULLY MINED NEW FUTURE DIRECTION!")
            print("=" * 60)
            print(f"Title: {direction.title}")
            print(f"Conjecture/Description:\n{direction.description}")
            if direction.lean_theorem_stub:
                print(f"\nProposed Lean Stub:\n{direction.lean_theorem_stub}")
            print(f"\nDomain Bridges: {direction.domain_bridges}")
            print(f"Catalog References: {direction.catalog_references}")
            print(f"Priority Score: {direction.priority_score:.2f}")
            print(f"Saved to: {research_memory._file}")
            print("=" * 60)
        else:
            print("[Error] Failed to parse a valid FutureDirection from Pi-Agent response.")
            print(f"Raw response preview:\n{raw[:500]}")
    except Exception as e:
        print(f"[Error] Mining failed: {e}")


if __name__ == "__main__":
    main()
