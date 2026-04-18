#!/usr/bin/env python3
"""
EML Paradigm Explorer — Interactive Research Discovery Tool

Explores synergies between EML and 50 AI paradigms, discovers new
cross-paradigm connections, and generates research hypotheses.

Usage:
    python eml_paradigm_explorer.py
"""

from dataclasses import dataclass, field
from typing import List, Dict, Set, Tuple
import itertools
import json


@dataclass
class Paradigm:
    name: str
    version: str
    category: str
    core_operation: str
    eml_connection: str
    theorems: List[str]
    key_insight: str
    compression_type: str  # "native", "direct", "multiplicative", "structural"


# Complete paradigm database (v1-v18)
PARADIGMS: Dict[str, Paradigm] = {
    "transformers": Paradigm(
        "Transformers", "v1-v8", "Architecture",
        "softmax = normalized exp", "Native EML",
        ["eml_activation_pos", "eml_activation_le_one"],
        "Softmax attention uses exp() which is EML's native operation",
        "native"
    ),
    "ssm": Paradigm(
        "State Space Models", "v13", "Architecture",
        "exp(ΔA) transition", "Native EML",
        ["eml_ssm_transition"],
        "SSM discretization uses matrix exponential",
        "native"
    ),
    "diffusion": Paradigm(
        "Diffusion Models", "v15", "Generative",
        "exp(-βt) noise schedule", "Native EML",
        ["eml_diffusion_schedule"],
        "Noise schedule and denoising use exponential decay",
        "native"
    ),
    "gnn": Paradigm(
        "Graph Neural Networks", "v15", "Architecture",
        "exp-based attention", "Native EML",
        ["eml_gnn_attention"],
        "Graph attention mechanism uses exp for attention weights",
        "native"
    ),
    "moe": Paradigm(
        "Mixture of Experts", "v14", "Scaling",
        "exp-based gating/routing", "Native EML",
        ["eml_moe_routing"],
        "Expert routing uses softmax gating over expert scores",
        "native"
    ),
    "energy_based": Paradigm(
        "Energy-Based Models", "v16", "Generative",
        "p(x) ∝ exp(-E(x))", "Native EML",
        ["eml_energy_model"],
        "Boltzmann distribution is a direct exponential",
        "native"
    ),
    "rl": Paradigm(
        "Reinforcement Learning", "v14", "Decision",
        "Boltzmann policy exp(Q/T)", "Native EML",
        ["eml_rl_policy"],
        "Boltzmann exploration uses temperature-scaled exp",
        "native"
    ),
    "speculative_decoding": Paradigm(
        "Speculative Decoding", "v17", "Inference",
        "Draft model size", "Direct benefit",
        ["eml_draft_compact", "eml_spec_step_cheaper", "eml_total_spec_cheaper"],
        "Smaller draft model enables more speculative tokens per step",
        "direct"
    ),
    "hypernetworks": Paradigm(
        "Hypernetworks", "v17", "Adaptation",
        "Weight generation cost", "Direct benefit",
        ["eml_hypernet_compact", "eml_weight_gen_cheaper"],
        "Compressed hypernetwork generates compressed target weights",
        "direct"
    ),
    "meta_learning": Paradigm(
        "Meta-Learning", "v17", "Adaptation",
        "Inner/outer loop cost", "Direct benefit",
        ["eml_maml_inner_cheaper", "eml_maml_outer_cheaper", "eml_fewshot_cheaper"],
        "MAML gradient computation scales with model size",
        "direct"
    ),
    "active_learning": Paradigm(
        "Active Learning", "v17", "Data",
        "Acquisition function cost", "Direct benefit",
        ["eml_acquisition_cheaper", "eml_mc_dropout_cheaper"],
        "Forward pass per sample for uncertainty estimation",
        "direct"
    ),
    "synthetic_data": Paradigm(
        "Synthetic Data", "v17", "Data",
        "Generation cost", "Direct benefit",
        ["eml_synthetic_cheaper", "eml_self_instruct_cheaper"],
        "LLM-based data generation at reduced cost per sample",
        "direct"
    ),
    "constitutional_ai": Paradigm(
        "Constitutional AI", "v17", "Safety",
        "Critique-revise cost", "Direct benefit",
        ["eml_critique_cheaper", "eml_cr_cycle_cheaper"],
        "Multiple critique-revise rounds per response",
        "direct"
    ),
    "neural_ode": Paradigm(
        "Neural ODEs", "v17", "Architecture",
        "f_θ evaluation cost", "Direct benefit",
        ["eml_ode_func_compact", "eml_solver_cheaper", "eml_adjoint_cheaper"],
        "ODE solver calls f_θ 20-100 times per forward pass",
        "direct"
    ),
    "world_models": Paradigm(
        "World Models", "v17", "Decision",
        "Dynamics computation", "Direct benefit",
        ["eml_dynamics_compact", "eml_imagination_cheaper", "eml_planning_cheaper"],
        "Planning requires imagining many future trajectories",
        "direct"
    ),
    "long_context": Paradigm(
        "Long Context", "v17", "Inference",
        "KV-cache size", "Direct benefit",
        ["eml_kv_cache_compact", "eml_compression_cheaper"],
        "KV-cache memory is proportional to d_model per token",
        "direct"
    ),
    "multi_agent": Paradigm(
        "Multi-Agent", "v17", "Collaboration",
        "Per-agent cost", "Direct benefit",
        ["eml_agent_cheaper", "eml_communication_cheaper", "eml_debate_cheaper"],
        "N agents × model size = N× memory requirement",
        "direct"
    ),
    # v18 paradigms
    "curriculum_learning": Paradigm(
        "Curriculum Learning", "v18", "Training",
        "Difficulty scoring cost", "Direct benefit",
        ["eml_train_step_cheaper", "eml_scoring_cheaper", "eml_curriculum_cheaper"],
        "Scoring sample difficulty requires forward passes",
        "direct"
    ),
    "program_synthesis": Paradigm(
        "Program Synthesis", "v18", "Generation",
        "Code generation cost", "Direct benefit",
        ["eml_codegen_cheaper", "eml_multicand_cheaper", "eml_refinement_cheaper"],
        "Generate and refine multiple code candidates",
        "direct"
    ),
    "federated_finetuning": Paradigm(
        "Federated Fine-Tuning", "v18", "Distributed",
        "Communication bandwidth", "Direct benefit",
        ["eml_local_cheaper", "eml_comm_cheaper", "eml_fed_total_cheaper"],
        "Model updates sent over network proportional to model size",
        "direct"
    ),
    "online_learning": Paradigm(
        "Online Learning", "v18", "Training",
        "Per-update latency", "Direct benefit",
        ["eml_update_cheaper", "eml_stream_cheaper", "eml_drift_cheaper"],
        "Real-time model updates require low-latency forward/backward",
        "direct"
    ),
    "prefix_tuning": Paradigm(
        "Prefix Tuning", "v18", "Adaptation",
        "Prefix parameter size", "Direct benefit",
        ["eml_prefix_compact", "eml_multitask_cheaper", "eml_prefix_train_cheaper"],
        "Soft prompt vectors proportional to d_model",
        "direct"
    ),
    "model_routing": Paradigm(
        "Model Routing", "v18", "Inference",
        "Portfolio memory", "Direct benefit",
        ["eml_portfolio_compact", "eml_routed_cheaper", "eml_cascade_cheaper"],
        "Multiple specialist models must fit in memory",
        "direct"
    ),
    "ensembles": Paradigm(
        "Ensemble Methods", "v18", "Uncertainty",
        "K× model cost", "Direct benefit",
        ["eml_ensemble_train_cheaper", "eml_ensemble_memory_compact",
         "eml_ensemble_inference_cheaper"],
        "K independent models for uncertainty estimation",
        "direct"
    ),
    "causal_discovery": Paradigm(
        "Causal Discovery", "v18", "Reasoning",
        "SEM fitting cost", "Direct benefit",
        ["eml_sem_cheaper", "eml_search_cheaper", "eml_causal_pipeline_cheaper"],
        "Score-based causal search fits model for each candidate graph",
        "direct"
    ),
    "memory_augmented": Paradigm(
        "Memory-Augmented Networks", "v18", "Architecture",
        "Controller + memory access", "Direct benefit",
        ["eml_controller_compact", "eml_read_cheaper", "eml_mann_cheaper"],
        "Controller network and memory keys scale with d_model",
        "direct"
    ),
    "reward_hacking": Paradigm(
        "Reward Hacking Detection", "v18", "Safety",
        "Reward ensemble cost", "Direct benefit",
        ["eml_reward_ensemble_cheaper", "eml_redteam_cheaper",
         "eml_safety_pipeline_cheaper"],
        "Multiple reward models for robust reward estimation",
        "direct"
    ),
}


def find_synergies() -> List[Tuple[str, str, str, float]]:
    """Discover synergies between paradigm pairs."""
    synergies = []
    categories = set(p.category for p in PARADIGMS.values())

    for (k1, p1), (k2, p2) in itertools.combinations(PARADIGMS.items(), 2):
        # Cross-category synergies are more interesting
        if p1.category != p2.category:
            # Compute synergy score based on complementarity
            score = 0.0

            # Different compression types multiply
            if p1.compression_type != p2.compression_type:
                score += 2.0

            # Training + Inference synergies
            train_cats = {"Training", "Adaptation", "Data"}
            infer_cats = {"Inference", "Generation", "Decision"}
            if (p1.category in train_cats and p2.category in infer_cats) or \
               (p2.category in train_cats and p1.category in infer_cats):
                score += 3.0

            # Safety + anything = important
            if p1.category == "Safety" or p2.category == "Safety":
                score += 2.0

            # New v18 paradigms are more novel
            if p1.version == "v18" or p2.version == "v18":
                score += 1.5

            # Both new = highest novelty
            if p1.version == "v18" and p2.version == "v18":
                score += 1.0

            if score >= 4.0:
                description = (
                    f"{p1.name} ({p1.core_operation}) × "
                    f"{p2.name} ({p2.core_operation})"
                )
                synergies.append((k1, k2, description, score))

    synergies.sort(key=lambda x: -x[3])
    return synergies


def generate_research_hypotheses() -> List[Dict]:
    """Generate novel research hypotheses from paradigm combinations."""
    hypotheses = []

    combos = [
        ("ensembles", "speculative_decoding",
         "Ensemble-Guided Speculative Decoding",
         "Use ensemble disagreement to set the number of draft tokens: "
         "high agreement → more draft tokens (higher acceptance), "
         "high disagreement → fewer drafts (save wasted computation). "
         "EML makes both the ensemble and draft model cheap enough to combine.",
         9),
        ("curriculum_learning", "synthetic_data",
         "Curriculum-Aware Synthetic Data Generation",
         "Generate synthetic training data at the current difficulty level of "
         "the curriculum. As the model improves, generate harder examples. "
         "EML enables rapid generation + scoring cycles.",
         8),
        ("model_routing", "meta_learning",
         "Meta-Learned Model Routing",
         "Use meta-learning to train the router: given a few examples from a "
         "new task, quickly determine which specialist model to route to. "
         "EML compresses both the router and the specialists.",
         8),
        ("causal_discovery", "world_models",
         "Causally-Structured World Models",
         "Learn a world model whose dynamics follow discovered causal structure. "
         "The causal graph constrains the dynamics model, improving sample "
         "efficiency and generalization. EML compresses both discovery and dynamics.",
         9),
        ("reward_hacking", "constitutional_ai",
         "Constitutional Reward Monitoring",
         "Use constitutional principles to detect reward hacking: if the model "
         "achieves high reward but violates constitutional principles, flag it. "
         "EML makes both the reward ensemble and the constitutional critic cheap.",
         10),
        ("memory_augmented", "long_context",
         "Hierarchical Memory for Ultra-Long Context",
         "Use a memory-augmented network as a 'summary cache' for long contexts: "
         "recent tokens in KV-cache, older tokens compressed into external memory. "
         "EML compresses both the KV-cache and the memory controller.",
         9),
        ("online_learning", "federated_finetuning",
         "Federated Online Adaptation",
         "Each client performs online learning on its local data stream, "
         "periodically sharing compressed model updates. EML reduces both "
         "per-update cost and communication bandwidth.",
         7),
        ("prefix_tuning", "model_routing",
         "Prefix-Routed Specialization",
         "Route inputs to different prefix configurations rather than different "
         "models. Same base model, different soft prompts. EML compresses both "
         "the base model and the prefix library.",
         8),
        ("program_synthesis", "active_learning",
         "Active Program Synthesis",
         "Use active learning to select which test cases are most informative "
         "for validating synthesized programs. Focus testing effort where "
         "the synthesizer is most uncertain.",
         7),
        ("ensembles", "reward_hacking",
         "Diverse Reward Ensembles for Robust Alignment",
         "Train reward models with diverse architectures (CNN, Transformer, "
         "GNN) in an EML-compressed ensemble. Diversity reduces reward hacking "
         "by preventing common failure modes.",
         9),
    ]

    for p1_key, p2_key, title, description, impact in combos:
        p1 = PARADIGMS[p1_key]
        p2 = PARADIGMS[p2_key]
        hypotheses.append({
            "title": title,
            "paradigms": [p1.name, p2.name],
            "versions": [p1.version, p2.version],
            "description": description,
            "impact_score": impact,
            "formal_foundation": [t for t in p1.theorems + p2.theorems],
            "status": "HYPOTHESIS"
        })

    return sorted(hypotheses, key=lambda h: -h["impact_score"])


def print_paradigm_matrix():
    """Print the full paradigm coverage matrix."""
    categories = {}
    for k, p in PARADIGMS.items():
        if p.category not in categories:
            categories[p.category] = []
        categories[p.category].append(p)

    print("\n" + "=" * 80)
    print("EML PARADIGM COVERAGE MATRIX (v1-v18)")
    print("=" * 80)

    for cat, paradigms in sorted(categories.items()):
        print(f"\n  {cat} ({len(paradigms)} paradigms)")
        print(f"  {'─' * 70}")
        for p in paradigms:
            conn_type = {"native": "★", "direct": "●", "multiplicative": "◆",
                         "structural": "◇"}
            icon = conn_type.get(p.compression_type, "○")
            print(f"    {icon} {p.name:<30} [{p.version}] {p.eml_connection}")


def main():
    print("=" * 80)
    print("EML PARADIGM EXPLORER v18")
    print("Discover synergies across 28+ AI paradigms")
    print("=" * 80)

    # Print coverage matrix
    print_paradigm_matrix()

    # Find synergies
    synergies = find_synergies()
    print(f"\n{'=' * 80}")
    print(f"TOP 20 CROSS-PARADIGM SYNERGIES (Score ≥ 4.0)")
    print(f"{'=' * 80}")

    for i, (k1, k2, desc, score) in enumerate(synergies[:20], 1):
        print(f"\n  {i:2d}. [{score:.1f}] {desc}")
        p1, p2 = PARADIGMS[k1], PARADIGMS[k2]
        print(f"      Categories: {p1.category} × {p2.category}")
        print(f"      Key theorems: {', '.join(p1.theorems[:2] + p2.theorems[:2])}")

    # Generate hypotheses
    hypotheses = generate_research_hypotheses()
    print(f"\n{'=' * 80}")
    print(f"TOP 10 RESEARCH HYPOTHESES")
    print(f"{'=' * 80}")

    for i, h in enumerate(hypotheses[:10], 1):
        print(f"\n  {i:2d}. [{h['impact_score']}/10] {h['title']}")
        print(f"      Paradigms: {' × '.join(h['paradigms'])}")
        print(f"      {h['description']}")
        print(f"      Formal: {', '.join(h['formal_foundation'][:4])}")

    # Statistics
    print(f"\n{'=' * 80}")
    print(f"STATISTICS")
    print(f"{'=' * 80}")
    print(f"  Total paradigms:     {len(PARADIGMS)}")
    print(f"  v18 new paradigms:   {sum(1 for p in PARADIGMS.values() if p.version == 'v18')}")
    print(f"  Total theorems:      {sum(len(p.theorems) for p in PARADIGMS.values())}")
    print(f"  Possible synergies:  {len(synergies)}")
    print(f"  High-impact (≥6.0):  {sum(1 for s in synergies if s[3] >= 6.0)}")
    print(f"  Categories covered:  {len(set(p.category for p in PARADIGMS.values()))}")

    native = sum(1 for p in PARADIGMS.values() if p.compression_type == "native")
    direct = sum(1 for p in PARADIGMS.values() if p.compression_type == "direct")
    print(f"  Native EML:          {native}")
    print(f"  Direct benefit:      {direct}")

    # Export to JSON
    output = {
        "paradigms": {k: {
            "name": p.name, "version": p.version, "category": p.category,
            "core_operation": p.core_operation, "eml_connection": p.eml_connection,
            "theorems": p.theorems, "compression_type": p.compression_type
        } for k, p in PARADIGMS.items()},
        "top_synergies": [{"pair": [k1, k2], "description": d, "score": s}
                          for k1, k2, d, s in synergies[:30]],
        "hypotheses": hypotheses,
    }

    with open("eml_paradigm_data.json", "w") as f:
        json.dump(output, f, indent=2)
    print(f"\n  Full data exported to eml_paradigm_data.json")

    print(f"\n{'=' * 80}")
    print(f"Exploration complete. {len(PARADIGMS)} paradigms analyzed.")
    print(f"{'=' * 80}")


if __name__ == "__main__":
    main()
