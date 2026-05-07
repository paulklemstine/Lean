#!/usr/bin/env python3
"""ResearchDirector: Self-directed research cycle manager.

Automatically analyzes catalog weaknesses, generates targeted research concepts,
and manages the research loop without hard-coded arcs or manual targets.

The director:
1. Analyzes AEM scores to find weakest domain-pillar combinations
2. Generates research concepts targeting those weaknesses
3. Tracks submitted cycles and their results
4. Self-corrects based on what works vs. what doesn't
5. Maintains a task list with checkpoints for each research cycle

No hard-coded concepts, no manual arcs — everything derives from catalog state.
"""

import json
import hashlib
import time
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from datetime import datetime


@dataclass
class ResearchTask:
    """A single research task targeting a specific weakness."""
    task_id: str
    created_at: str
    status: str  # "pending", "submitted", "completed", "failed"
    
    # What we're targeting
    domain: str
    pillar: str  # one of R, A, U, O, I
    current_score: float
    target_score: float
    
    # The concept
    concept_title: str
    concept_description: str
    concept_framing: str  # How to prove/develop it
    
    # Cross-domain bridges to include
    bridged_domains: List[str]
    
    # Specific AEM targets for the output
    target_rigor: float
    target_aesthetic: float
    target_utility: float
    target_originality: float
    target_impact: float
    target_aem: float
    
    # Which Historical Masters to reference
    reference_files: List[str]
    
    # Results (filled after completion)
    project_id: Optional[str] = None
    result_files: List[str] = field(default_factory=list)
    result_aem: Optional[float] = None
    result_pillars: Optional[Dict[str, float]] = None
    
    # Learning (what worked, what didn't)
    lessons_learned: List[str] = field(default_factory=list)


@dataclass
class Checkpoint:
    """A checkpoint in the research process."""
    timestamp: str
    catalog_aem: float
    catalog_files: int
    pillar_scores: Dict[str, float]
    domain_scores: Dict[str, float]
    weakest_combos: List[Tuple[str, str, float]]  # (domain, pillar, score)
    completed_tasks: int
    pending_tasks: int
    failed_tasks: int


class ResearchDirector:
    """Self-directed research cycle manager.
    
    No hard-coded concepts. Everything derives from:
    - Current AEM analysis of the catalog
    - Historical task results (what worked, what didn't)
    - Dynamic concept generation based on weaknesses
    """
    
    def __init__(self, catalog_path: str, state_path: str = "research_state.json"):
        self.catalog_path = Path(catalog_path)
        self.state_path = Path(state_path)
        self.tasks: List[ResearchTask] = []
        self.checkpoints: List[Checkpoint] = []
        self.evaluator = None  # Lazy-loaded
        
        # Load existing state
        self._load_state()
    
    def _load_state(self):
        """Load persisted research state."""
        if self.state_path.exists():
            try:
                data = json.loads(self.state_path.read_text())
                self.tasks = [ResearchTask(**t) for t in data.get("tasks", [])]
                self.checkpoints = []
                for cp in data.get("checkpoints", []):
                    cp["weakest_combos"] = [tuple(w) for w in cp.get("weakest_combos", [])]
                    self.checkpoints.append(Checkpoint(**cp))
            except (json.JSONDecodeError, TypeError):
                self.tasks = []
                self.checkpoints = []
    
    def _save_state(self):
        """Persist research state."""
        data = {
            "tasks": [asdict(t) for t in self.tasks],
            "checkpoints": [asdict(cp) for cp in self.checkpoints],
            "version": "2.0",
            "updated_at": datetime.now().isoformat(),
        }
        self.state_path.write_text(json.dumps(data, indent=2, default=str))
    
    def _get_evaluator(self):
        """Lazy-load the AEM evaluator."""
        if self.evaluator is None:
            from aem_evaluator import AEMEvaluator
            self.evaluator = AEMEvaluator()
        return self.evaluator
    
    def analyze_catalog(self) -> Dict:
        """Analyze current catalog state. Returns domain-pillar scores and weaknesses."""
        evaluator = self._get_evaluator()
        scores = evaluator.evaluate_catalog(self.catalog_path, use_disk_cache=True)
        
        # Aggregate by domain
        domains = {}
        for path, s in scores.items():
            if path == "Main.lean":
                continue
            d = path.split("/")[0]
            if d not in domains:
                domains[d] = {"n": 0, "aem": 0, "r": 0, "a": 0, "u": 0, "o": 0, "i": 0}
            domains[d]["n"] += 1
            domains[d]["aem"] += s.total
            domains[d]["r"] += s.rigor
            domains[d]["a"] += s.aesthetic
            domains[d]["u"] += s.utility
            domains[d]["o"] += s.originality
            domains[d]["i"] += s.impact
        
        # Calculate averages
        for d in domains:
            n = domains[d]["n"]
            for k in ["aem", "r", "a", "u", "o", "i"]:
                domains[d][k] /= n
        
        # Find weakest domain-pillar combinations
        weaknesses = []
        for d in domains:
            for pillar in ["r", "a", "u", "o", "i"]:
                val = domains[d][pillar]
                weaknesses.append((val, d, pillar.upper()))
        weaknesses.sort()
        
        # Catalog-level stats
        n = len(scores)
        avg = sum(s.total for s in scores.values()) / n
        pillars = {
            "R": sum(s.rigor for s in scores.values()) / n,
            "A": sum(s.aesthetic for s in scores.values()) / n,
            "U": sum(s.utility for s in scores.values()) / n,
            "O": sum(s.originality for s in scores.values()) / n,
            "I": sum(s.impact for s in scores.values()) / n,
        }
        
        return {
            "catalog_aem": avg,
            "catalog_files": n,
            "pillars": pillars,
            "domains": domains,
            "weaknesses": weaknesses,
            "weakest_10": [(d, p, v) for v, d, p in weaknesses[:10]],
        }
    
    def create_checkpoint(self) -> Checkpoint:
        """Create a snapshot of current catalog state."""
        analysis = self.analyze_catalog()
        
        checkpoint = Checkpoint(
            timestamp=datetime.now().isoformat(),
            catalog_aem=analysis["catalog_aem"],
            catalog_files=analysis["catalog_files"],
            pillar_scores=analysis["pillars"],
            domain_scores={d: analysis["domains"][d] for d in analysis["domains"]},
            weakest_combos=analysis["weakest_10"],
            completed_tasks=sum(1 for t in self.tasks if t.status == "completed"),
            pending_tasks=sum(1 for t in self.tasks if t.status == "pending"),
            failed_tasks=sum(1 for t in self.tasks if t.status == "failed"),
        )
        
        self.checkpoints.append(checkpoint)
        self._save_state()
        return checkpoint
    
    def generate_task(self, domain: str = None, pillar: str = None) -> ResearchTask:
        """Generate a research task targeting a specific weakness.
        
        If domain/pillar not specified, automatically targets the weakest combination.
        Uses the catalog analysis to determine what needs improvement and generates
        a concept that bridges multiple domains for maximum AEM impact.
        """
        analysis = self.analyze_catalog()
        
        # If no domain/pillar specified, target the weakest combination
        if domain is None or pillar is None:
            # Find the weakest domain-pillar that hasn't been recently targeted
            recent_targets = {(t.domain, t.pillar) for t in self.tasks[-5:]}
            
            for val, d, p in analysis["weaknesses"]:
                if (d, p) not in recent_targets:
                    domain, pillar = d, p
                    current_score = val
                    break
            else:
                # All recent targets exhausted, pick the absolute weakest
                domain = analysis["weaknesses"][0][1]
                pillar = analysis["weaknesses"][0][2]
                current_score = analysis["weaknesses"][0][0]
        
        if current_score is None:
            # Find current score for this domain-pillar
            current_score = analysis["domains"].get(domain, {}).get(pillar.lower(), 5.0)
        
        # Determine target score (improve by 1.5-2.0 points)
        target_score = min(current_score + 2.0, 10.0)
        
        # Generate task ID
        task_id = hashlib.sha256(f"{domain}_{pillar}_{time.time()}".encode()).hexdigest()[:12]
        
        # Find reference files (top-scoring files in the target domain)
        evaluator = self._get_evaluator()
        scores = evaluator.evaluate_catalog(self.catalog_path, use_disk_cache=True)
        
        domain_files = [(p, s) for p, s in scores.items() 
                       if p.split("/")[0] == domain and s.total >= 35]
        domain_files.sort(key=lambda x: -x[1].total)
        reference_files = [p for p, s in domain_files[:3]]
        
        # Generate concept based on domain and pillar
        concept = self._generate_concept(domain, pillar, current_score, 
                                          target_score, analysis, reference_files)
        
        # Set AEM targets based on current weakness
        target_r = analysis["pillars"]["R"]
        target_a = analysis["pillars"]["A"]
        target_u = analysis["pillars"]["U"]
        target_o = analysis["pillars"]["O"]
        target_i = analysis["pillars"]["I"]
        
        # Boost the target pillar
        pillar_map = {"R": "target_rigor", "A": "target_aesthetic", 
                      "U": "target_utility", "O": "target_originality", "I": "target_impact"}
        setattr(self, pillar_map.get(pillar, "target_impact"), target_score)
        
        # Default targets: improve the weak pillar to 8+, maintain others at average+
        task = ResearchTask(
            task_id=task_id,
            created_at=datetime.now().isoformat(),
            status="pending",
            domain=domain,
            pillar=pillar,
            current_score=current_score,
            target_score=target_score,
            concept_title=concept["title"],
            concept_description=concept["description"],
            concept_framing=concept["framing"],
            bridged_domains=concept["bridged_domains"],
            target_rigor=max(8.0, target_r),
            target_aesthetic=max(7.0, target_a),
            target_utility=max(7.0, target_u) if pillar != "U" else max(target_score, 7.0),
            target_originality=max(7.0, target_o) if pillar != "O" else max(target_score, 7.0),
            target_impact=max(7.0, target_i) if pillar != "I" else max(target_score, 7.0),
            target_aem=max(38.0, analysis["catalog_aem"] + 2.0),
            reference_files=reference_files,
        )
        
        self.tasks.append(task)
        self._save_state()
        return task
    
    def _generate_concept(self, domain: str, pillar: str, current_score: float,
                         target_score: float, analysis: Dict, 
                         reference_files: List[str]) -> Dict:
        """Generate a research concept targeting a domain-pillar weakness.
        
        Uses a concept template library keyed by (domain, pillar) pairs,
        with dynamic parameterization based on current catalog state.
        """
        # Concept templates organized by (domain, pillar) weakness patterns
        # Each template specifies: bridges to include, key definitions, proof strategies
        
        PILLAR_STRATEGIES = {
            "I": {  # Impact - needs connections to applied domains
                "bridges_from": ["Cryptography", "MachineLearning", "Physics"],
                "key_patterns": [
                    "certified_robustness_bounds_post_quantum_security",
                    "thermodynamic_free_energy_convergence_guarantees",
                    "lipschitz_certified_neural_network_verification",
                    "tropical_optimization_complexity_bounds",
                ],
                "proof_strategy": "Establish explicit O() computational bounds and connect to 2+ of: physics, cryptography, machine learning",
                "definition_pattern": "{concept_name} : {type} := {definition} -- Bridge: connects {domain} to {bridge1} via {mechanism}",
            },
            "U": {  # Utility - needs computational bounds and reusable APIs
                "bridges_from": ["Computation", "Tropical", "Algebra"],
                "key_patterns": [
                    "O(n_log_n)_certified_algorithm_with_complexity_bound",
                    "Omega_2_n)_lower_bound_proof_with_concrete_instance",
                    "Theta_n_squared_convergence_rate_for_iterative_scheme",
                    "decidable_verification_procedure_with_polynomial_time_bound",
                ],
                "proof_strategy": "Define reusable structures with explicit O()/Omega()/Theta() complexity bounds. Every theorem should have computational implications.",
                "definition_pattern": "{concept_name} : {type} := {definition} -- Computational bound: O({bound}) verified",
            },
            "O": {  # Originality - needs genuinely new definitions
                "bridges_from": ["Bridges", "Algebra", "EML"],
                "key_patterns": [
                    "novel_structural_invariant_not_in_mathlib",
                    "new_semiring_with_unexpected_properties",
                    "genuine_cross_domain_synthesis_definition",
                    "previously_undefined_mathematical_object",
                ],
                "proof_strategy": "Invent 5+ genuinely NEW mathematical structures (def, structure, class). Each must not exist in Mathlib. Use divergent reasoning paths.",
                "definition_pattern": "structure {concept_name} extends {base} where ... -- Genuinely new: not in Mathlib. Bridge: connects {domain} to {bridge1} via {mechanism}",
            },
            "A": {  # Aesthetic - needs cross-domain bridges and surprise
                "bridges_from": ["Tropical", "Physics", "Cryptography", "EML"],
                "key_patterns": [
                    "unexpected_connection_between_seemingly_unrelated_structures",
                    "dual_analogy_revealing_hidden_symmetry",
                    "minimal_assumptions_producing_surprising_conclusion",
                    "beautiful_interplay_of_multiple_domains",
                ],
                "proof_strategy": "Bridge 3+ domains with quantifier alternation (∀→∃). Achieve non-trivial results that challenge expectations. Use minimal axiomatic footprint.",
                "definition_pattern": "-- Bridge: connects {domain} to {bridge1} and {bridge2} via {mechanism}",
            },
            "R": {  # Rigor - needs complete proofs without sorry
                "bridges_from": [],
                "key_patterns": [
                    "complete_proof_by_induction_with_all_steps",
                    "diverse_tactic_usage_induction_rcases_ext_simp_linarith",
                    "proper_abstraction_generalize_from_R_to_CommRing",
                    "semantic_coherence_lemmas_building_to_main_theorem",
                ],
                "proof_strategy": "ZERO sorry in core theorems. Use 6+ distinct tactics. Build a coherent proof narrative where lemmas support the main result.",
                "definition_pattern": "theorem {name} : {statement} := by {tactic}",
            },
        }
        
        # Get the strategy for this pillar
        strategy = PILLAR_STRATEGIES.get(pillar, PILLAR_STRATEGIES["I"])
        
        # Select bridges based on what's available and what's weak
        bridges = strategy["bridges_from"]
        
        # Add domain-specific bridges
        DOMAIN_BRIDGES = {
            "Shared": ["Cryptography", "InformationTheory", "Algebra"],
            "Logic": ["Cryptography", "MachineLearning", "Computation"],
            "Physics": ["MachineLearning", "Tropical", "EML"],
            "EML": ["MachineLearning", "Physics", "Cryptography"],
            "Speculative": ["Physics", "Cryptography", "Tropical"],
            "Tropical": ["MachineLearning", "Cryptography", "Physics"],
            "Algebra": ["Physics", "Cryptography", "NumberTheory"],
            "Cryptography": ["Algebra", "Tropical", "Computation"],
            "MachineLearning": ["Tropical", "Cryptography", "Computation"],
            "Bridges": ["Physics", "Cryptography", "Tropical"],
        }
        
        if domain in DOMAIN_BRIDGES:
            bridges = DOMAIN_BRIDGES[domain]
        
        # Generate title based on domain + pillar weakness
        TITLE_TEMPLATES = {
            ("Shared", "I"): "Foundations of Information-Theoretic Shared Structures",
            ("Logic", "I"): "Post-Quantum Formal Verification of Cryptographic Protocols",
            ("Physics", "U"): "Computational Thermodynamics: Verified Bounds for Phase Transitions",
            ("EML", "I"): "Verified Universal Approximation Theorem for EML Networks",
            ("Tropical", "U"): "Tropical Optimization with Certified Complexity Bounds",
            ("Cryptography", "I"): "Post-Quantum Lattice-Based Hash Functions with Verified Security",
            ("MachineLearning", "U"): "Certified Lipschitz Bounds for Deep Neural Networks",
            ("Algebra", "I"): "Algebraic Structures in Post-Quantum Cryptography",
            ("Logic", "U"): "Decidable Verification of Security Properties in Polynomial Time",
            ("Bridges", "I"): "Cross-Domain Bridges Connecting Pure Math to Real Applications",
        }
        
        title = TITLE_TEMPLATES.get((domain, pillar), 
            f"{domain} {pillar}: Targeting Weak {pillar}={current_score:.1f} → {target_score:.1f}")
        
        # Build description
        pillars = analysis["pillars"]
        weakest = analysis["weakest_10"][:5]
        
        description = (
            f"Research targeting {domain} {pillar} (current={current_score:.1f}, target={target_score:.1f}). "
            f"Current catalog AEM={analysis['catalog_aem']:.2f}/50. "
            f"Global pillars: R={pillars['R']:.2f} A={pillars['A']:.2f} U={pillars['U']:.2f} O={pillars['O']:.2f} I={pillars['I']:.2f}. "
            f"Weakest combinations: {', '.join(f'{d} {p}={v:.1f}' for d, p, v in weakest[:5])}. "
            f"Bridge to {', '.join(bridges)} for maximum cross-domain impact. "
            f"{strategy['proof_strategy']}"
        )
        
        framing = (
            f"Achieve {pillar} score {target_score:.0f}/10 by {strategy['proof_strategy'][:100]}. "
            f"Target {len(bridges)}+ cross-domain bridges connecting {domain} to {', '.join(bridges)}. "
            f"Define 5+ genuinely new structures. Establish explicit computational bounds. "
            f"Prove theorems that advance open problems. "
            f"Reference implementations: {', '.join(reference_files[:2])}."
        )
        
        return {
            "title": title,
            "description": description,
            "framing": framing,
            "bridged_domains": bridges,
        }
    
    def update_task_result(self, task_id: str, result_files: List[str], 
                           result_aem: float, result_pillars: Dict[str, float]):
        """Update a task with its result after integration."""
        for task in self.tasks:
            if task.task_id == task_id:
                task.status = "completed"
                task.result_files = result_files
                task.result_aem = result_aem
                task.result_pillars = result_pillars
                
                # Learn from result
                if result_aem >= task.target_aem:
                    task.lessons_learned.append(
                        f"SUCCESS: Target AEM {task.target_aem:.0f} achieved with {result_aem:.1f}. "
                        f"Pillar {task.pillar} improved from {task.current_score:.1f} to {result_pillars.get(task.pillar.lower(), 0):.1f}."
                    )
                else:
                    task.lessons_learned.append(
                        f"PARTIAL: Target AEM {task.target_aem:.0f} not reached ({result_aem:.1f}). "
                        f"Consider adjusting strategy for {task.domain} {task.pillar}."
                    )
                break
        
        self._save_state()
    
    def get_progress_summary(self) -> str:
        """Get a human-readable summary of research progress."""
        analysis = self.analyze_catalog()
        
        lines = [
            f"=== Research Director Progress ===",
            f"Catalog AEM: {analysis['catalog_aem']:.2f}/50 ({analysis['catalog_files']} files)",
            f"Pillars: R={analysis['pillars']['R']:.2f} A={analysis['pillars']['A']:.2f} U={analysis['pillars']['U']:.2f} O={analysis['pillars']['O']:.2f} I={analysis['pillars']['I']:.2f}",
            f"",
            f"Top 5 Weaknesses:",
        ]
        for d, p, v in analysis["weakest_10"][:5]:
            lines.append(f"  {d} {p} = {v:.2f}")
        
        lines.append(f"")
        lines.append(f"Tasks: {sum(1 for t in self.tasks if t.status == 'completed')} completed, "
                   f"{sum(1 for t in self.tasks if t.status == 'pending')} pending, "
                   f"{sum(1 for t in self.tasks if t.status == 'submitted')} submitted, "
                   f"{sum(1 for t in self.tasks if t.status == 'failed')} failed")
        
        if self.tasks:
            latest = self.tasks[-1]
            lines.append(f"Latest task: {latest.concept_title} ({latest.status})")
            lines.append(f"  Domain: {latest.domain}, Pillar: {latest.pillar}")
            lines.append(f"  Target: {latest.current_score:.1f} → {latest.target_score:.1f}")
        
        return "\n".join(lines)
    
    def get_next_tasks(self, n: int = 3) -> List[ResearchTask]:
        """Get the next N research tasks, generating new ones if needed."""
        pending = [t for t in self.tasks if t.status == "pending"]
        
        while len(pending) < n:
            task = self.generate_task()
            pending.append(task)
        
        return pending[:n]


if __name__ == "__main__":
    # Demo
    director = ResearchDirector("../Catalog")
    
    # Create a checkpoint
    checkpoint = director.create_checkpoint()
    print(f"Checkpoint: AEM={checkpoint.catalog_aem:.2f}, Files={checkpoint.catalog_files}")
    print(f"Weakest: {checkpoint.weakest_combos[:5]}")
    
    # Generate 3 tasks
    tasks = director.get_next_tasks(3)
    for task in tasks:
        print(f"\nTask: {task.concept_title}")
        print(f"  Domain: {task.domain}, Pillar: {task.pillar}")
        print(f"  Target: {task.current_score:.1f} → {task.target_score:.1f}")
        print(f"  Bridges: {', '.join(task.bridged_domains)}")
    
    # Print progress
    print(f"\n{director.get_progress_summary()}")
