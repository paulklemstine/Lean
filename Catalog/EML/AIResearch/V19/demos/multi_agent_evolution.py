#!/usr/bin/env python3
"""
Multi-Agent Evolutionary Self-Play Simulator
=============================================

Simulates a population of self-improving AI agents that compete, co-evolve,
and transfer knowledge. Demonstrates the theorems from MultiAgentSelfPlay.lean
and StochasticSelfImprovement.lean.

Key features:
- Population-based training with selection pressure (tournament selection)
- Elo rating dynamics with conservation verification
- Cross-agent skill transfer with similarity-based efficiency
- Diversity tracking and its effect on population improvement
- Noisy self-improvement with Polyak averaging
- EML vs standard agent efficiency comparison

References:
  - avg_performance_bounded: Average performance stays in [0,1]
  - elo_conservation: Total Elo is conserved after updates
  - diversity_nonneg: Population diversity is always nonneg
  - zero_diversity_uniform: Zero diversity means all agents identical
  - population_improves: If every agent improves, population improves
  - eml_more_agents: EML enables more agents per compute budget
  - noisy_contraction_residual_bound: Noisy improvement has a noise floor
  - polyak_average_bounded: Polyak average stays bounded
"""

import json
import math
import random
from dataclasses import dataclass, field
from typing import List, Dict, Tuple

# ─── Agent Model ───────────────────────────────────────────────────────────────

@dataclass
class Agent:
    """A self-improving agent with performance across multiple tasks."""
    agent_id: int
    performances: List[float]  # Performance on each task, in [0,1]
    elo_rating: float = 1500.0
    generation: int = 0
    is_eml: bool = False
    history: List[float] = field(default_factory=list)

    @property
    def avg_performance(self) -> float:
        return sum(self.performances) / len(self.performances) if self.performances else 0.0

    def improve(self, noise_std: float = 0.02, contraction_rate: float = 0.95) -> None:
        """Self-improvement step: contraction toward optimum + noise.
        Ref: noisy_contraction_residual_bound — noise floor = σ/(1-c)"""
        for i in range(len(self.performances)):
            target = 1.0  # Optimal performance
            improvement = (1 - contraction_rate) * (target - self.performances[i])
            noise = random.gauss(0, noise_std)
            self.performances[i] = max(0, min(1, self.performances[i] + improvement + noise))
        self.history.append(self.avg_performance)


# ─── Elo System ────────────────────────────────────────────────────────────────

def elo_expected_score(rating_diff: float) -> float:
    """Expected score from Elo system. Ref: elo_expected_in_unit — always in (0,1)."""
    return 1.0 / (1.0 + math.exp(-rating_diff / 400.0))

def elo_update(winner: Agent, loser: Agent, K: float = 32.0) -> Tuple[float, float]:
    """Update Elo ratings. Ref: elo_conservation — total Elo is conserved."""
    expected_winner = elo_expected_score(winner.elo_rating - loser.elo_rating)
    delta = K * (1 - expected_winner)
    winner.elo_rating += delta
    loser.elo_rating -= delta
    return delta, -delta


# ─── Population Dynamics ──────────────────────────────────────────────────────

def compute_diversity(agents: List[Agent]) -> float:
    """Population diversity (variance). Ref: diversity_nonneg — always ≥ 0."""
    if not agents:
        return 0.0
    avg = sum(a.avg_performance for a in agents) / len(agents)
    return sum((a.avg_performance - avg) ** 2 for a in agents) / len(agents)

def tournament_select(agents: List[Agent], tournament_size: int = 3) -> Agent:
    """Tournament selection: higher selection pressure with larger tournament."""
    candidates = random.sample(agents, min(tournament_size, len(agents)))
    return max(candidates, key=lambda a: a.avg_performance)

def transfer_knowledge(source: Agent, target: Agent, similarity: float) -> None:
    """Cross-agent skill transfer. Ref: transfer_le_similarity, transfer_le_overlap."""
    task_overlap = sum(1 for s, t in zip(source.performances, target.performances)
                       if abs(s - t) < 0.3) / len(source.performances)
    efficiency = similarity * task_overlap  # transferEfficiency
    for i in range(len(target.performances)):
        if source.performances[i] > target.performances[i]:
            gain = efficiency * (source.performances[i] - target.performances[i])
            target.performances[i] = min(1.0, target.performances[i] + gain * 0.1)

def polyak_average(history: List[float]) -> float:
    """Polyak average for variance reduction. Ref: polyak_average_bounded."""
    if not history:
        return 0.0
    return sum(history) / len(history)


# ─── Simulation ───────────────────────────────────────────────────────────────

def run_simulation(
    num_agents: int = 20,
    num_tasks: int = 10,
    num_generations: int = 50,
    selection_pressure: float = 0.3,
    noise_std: float = 0.02,
    transfer_prob: float = 0.2,
    seed: int = 42
) -> Dict:
    """Run a complete multi-agent evolutionary simulation."""
    random.seed(seed)

    # Initialize population
    agents = [
        Agent(
            agent_id=i,
            performances=[random.uniform(0.1, 0.4) for _ in range(num_tasks)],
            is_eml=(i >= num_agents // 2)  # Half the agents use EML
        )
        for i in range(num_agents)
    ]

    results = {
        "config": {
            "num_agents": num_agents,
            "num_tasks": num_tasks,
            "num_generations": num_generations,
            "selection_pressure": selection_pressure,
            "noise_std": noise_std,
        },
        "generations": [],
        "elo_conservation_checks": [],
        "theorem_references": [],
    }

    for gen in range(num_generations):
        # ─── Self-play matches ─────────────────────────────────────
        total_elo_before = sum(a.elo_rating for a in agents)
        matches = random.sample(list(range(num_agents)), num_agents)
        for k in range(0, len(matches) - 1, 2):
            a1, a2 = agents[matches[k]], agents[matches[k+1]]
            # Determine winner based on performance
            if a1.avg_performance > a2.avg_performance:
                elo_update(a1, a2)
            elif a2.avg_performance > a1.avg_performance:
                elo_update(a2, a1)
        total_elo_after = sum(a.elo_rating for a in agents)

        # Verify Elo conservation (ref: elo_conservation)
        elo_conserved = abs(total_elo_after - total_elo_before) < 1e-10
        results["elo_conservation_checks"].append(elo_conserved)

        # ─── Self-improvement ──────────────────────────────────────
        for agent in agents:
            # EML agents have lower noise (ref: eml_lower_gradient_noise)
            agent_noise = noise_std * (0.5 if agent.is_eml else 1.0)
            agent.improve(noise_std=agent_noise)

        # ─── Knowledge transfer ────────────────────────────────────
        for agent in agents:
            if random.random() < transfer_prob:
                source = tournament_select(agents)
                if source.agent_id != agent.agent_id:
                    similarity = 0.5 + 0.5 * random.random()
                    transfer_knowledge(source, agent, similarity)

        # ─── Selection (replace worst agents) ──────────────────────
        num_replace = max(1, int(selection_pressure * num_agents))
        agents_sorted = sorted(agents, key=lambda a: a.avg_performance)
        for idx in range(num_replace):
            parent = tournament_select(agents, tournament_size=5)
            child = Agent(
                agent_id=agents_sorted[idx].agent_id,
                performances=[
                    max(0, min(1, p + random.gauss(0, 0.05)))
                    for p in parent.performances
                ],
                elo_rating=1500.0,
                generation=gen + 1,
                is_eml=parent.is_eml,
            )
            agents[agents.index(agents_sorted[idx])] = child

        # ─── Record statistics ─────────────────────────────────────
        avg_perf = sum(a.avg_performance for a in agents) / len(agents)
        max_perf = max(a.avg_performance for a in agents)
        diversity = compute_diversity(agents)
        eml_avg = sum(a.avg_performance for a in agents if a.is_eml) / max(1, sum(1 for a in agents if a.is_eml))
        std_avg = sum(a.avg_performance for a in agents if not a.is_eml) / max(1, sum(1 for a in agents if not a.is_eml))

        gen_data = {
            "generation": gen,
            "avg_performance": round(avg_perf, 4),
            "max_performance": round(max_perf, 4),
            "diversity": round(diversity, 6),
            "eml_avg_performance": round(eml_avg, 4),
            "std_avg_performance": round(std_avg, 4),
            "total_elo": round(total_elo_after, 2),
            "elo_conserved": elo_conserved,
        }
        results["generations"].append(gen_data)

        if gen % 10 == 0:
            print(f"Gen {gen:3d}: avg={avg_perf:.4f}  max={max_perf:.4f}  "
                  f"div={diversity:.6f}  EML={eml_avg:.4f}  STD={std_avg:.4f}")

    # ─── Theorem verification summary ─────────────────────────────
    final_gen = results["generations"][-1]
    initial_gen = results["generations"][0]

    results["theorem_references"] = [
        {
            "theorem": "avg_performance_bounded",
            "statement": "Average performance is in [0,1]",
            "verified": 0 <= final_gen["avg_performance"] <= 1,
            "value": final_gen["avg_performance"],
        },
        {
            "theorem": "elo_conservation",
            "statement": "Total Elo is conserved after updates",
            "verified": all(results["elo_conservation_checks"]),
            "violations": sum(1 for c in results["elo_conservation_checks"] if not c),
        },
        {
            "theorem": "diversity_nonneg",
            "statement": "Population diversity is nonneg",
            "verified": all(g["diversity"] >= 0 for g in results["generations"]),
        },
        {
            "theorem": "population_improves",
            "statement": "Population fitness increases over time",
            "verified": final_gen["avg_performance"] > initial_gen["avg_performance"],
            "initial": initial_gen["avg_performance"],
            "final": final_gen["avg_performance"],
        },
        {
            "theorem": "eml_more_agents / eml_lower_gradient_noise",
            "statement": "EML agents improve faster due to lower noise",
            "verified": final_gen["eml_avg_performance"] >= final_gen["std_avg_performance"],
            "eml_final": final_gen["eml_avg_performance"],
            "std_final": final_gen["std_avg_performance"],
        },
    ]

    # Polyak averaging demonstration
    for agent in agents[:3]:
        if agent.history:
            polyak_avg = polyak_average(agent.history)
            results["theorem_references"].append({
                "theorem": "polyak_average_bounded",
                "statement": f"Agent {agent.agent_id} Polyak avg is bounded",
                "verified": 0 <= polyak_avg <= 1,
                "value": round(polyak_avg, 4),
            })

    return results


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("  Multi-Agent Evolutionary Self-Play Simulator")
    print("  Demonstrates: MultiAgentSelfPlay.lean + StochasticSelfImprovement.lean")
    print("=" * 70)
    print()

    results = run_simulation(
        num_agents=30,
        num_tasks=8,
        num_generations=50,
        selection_pressure=0.25,
        noise_std=0.015,
        transfer_prob=0.3,
        seed=42
    )

    print()
    print("=" * 70)
    print("  THEOREM VERIFICATION SUMMARY")
    print("=" * 70)
    for ref in results["theorem_references"]:
        status = "✓" if ref["verified"] else "✗"
        print(f"  {status} {ref['theorem']}: {ref['statement']}")
        for k, v in ref.items():
            if k not in ("theorem", "statement", "verified"):
                print(f"      {k}: {v}")

    print()
    print(f"  Total generations: {len(results['generations'])}")
    print(f"  Final avg performance: {results['generations'][-1]['avg_performance']}")
    print(f"  Final max performance: {results['generations'][-1]['max_performance']}")
    print(f"  Final diversity: {results['generations'][-1]['diversity']}")

    # Save results
    with open("multi_agent_results.json", "w") as f:
        json.dump(results, f, indent=2)
    print("\n  Results saved to multi_agent_results.json")
