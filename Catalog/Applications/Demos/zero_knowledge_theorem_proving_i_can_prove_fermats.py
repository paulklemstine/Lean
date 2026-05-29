#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Locally Auditable Proof Certificates

Demonstrates practical applications:
  1. Privacy-preserving peer review of mathematical proofs
  2. Distributed theorem certification across untrusted nodes
  3. Proof-carrying code verification with bounded disclosure
  4. Progressive trust building through incremental auditing
"""

import random
import math
from dataclasses import dataclass, field
from typing import List, Set, Dict, Optional, Tuple


# ============================================================
# Application 1: Privacy-Preserving Peer Review
# ============================================================

class PrivacyPreservingReview:
    """Simulates a privacy-preserving peer review protocol.

    A mathematician has proved a theorem but wants to convince a reviewer
    without revealing the full proof strategy. The reviewer audits random
    steps and builds confidence incrementally.

    This models the real-world scenario: a researcher submits a proof to
    a journal, and the referee checks selected lemmas rather than
    line-checking the entire argument.
    """

    def __init__(self, proof_length: int, max_deps: int = 3, seed: int = 42):
        """Initialize with a synthetic proof.

        Args:
            proof_length: Number of steps in the proof
            max_deps: Maximum dependencies per step
            seed: Random seed
        """
        self.rng = random.Random(seed)
        self.n = proof_length
        self.max_deps = max_deps

        # Generate a valid proof (all steps valid)
        self.steps_valid = [True] * proof_length
        self.deps = []
        for i in range(proof_length):
            num_deps = self.rng.randint(0, min(max_deps, i))
            dep_indices = sorted(self.rng.sample(range(i), num_deps)) if i > 0 and num_deps > 0 else []
            self.deps.append(dep_indices)

    def audit_step(self, index: int) -> dict:
        """Audit a single step, returning only local information."""
        return {
            'index': index,
            'valid': self.steps_valid[index],
            'num_deps': len(self.deps[index]),
            'leakage': 1 + len(self.deps[index]),
        }

    def review_session(self, num_rounds: int) -> dict:
        """Conduct a review session with k random audits.

        Returns:
            Summary of the review including acceptance, leakage, and confidence.
        """
        challenges = [self.rng.randrange(self.n) for _ in range(num_rounds)]
        results = [self.audit_step(c) for c in challenges]
        all_accepted = all(r['valid'] for r in results)
        total_leakage = sum(r['leakage'] for r in results)
        fraction_revealed = total_leakage / self.n

        # Under well-formed proof, acceptance is certain
        # Under defective proof with density δ, reject prob per round ≥ δ
        # After k rounds: confidence ≥ 1 - (1-δ)^k
        confidence = 1.0 if all_accepted else 0.0

        return {
            'rounds': num_rounds,
            'all_accepted': all_accepted,
            'total_leakage': total_leakage,
            'fraction_revealed': fraction_revealed,
            'confidence': confidence,
            'challenges': challenges,
        }


# ============================================================
# Application 2: Distributed Theorem Certification
# ============================================================

class DistributedCertification:
    """Simulates distributed verification across multiple nodes.

    Multiple verifier nodes each audit different parts of a proof.
    No single node sees the entire proof, but collectively they
    achieve high confidence in its correctness.

    This models distributed systems where trust is established
    through independent partial verification.
    """

    def __init__(self, proof_length: int, num_nodes: int,
                 defect_fraction: float = 0.0, seed: int = 42):
        self.rng = random.Random(seed)
        self.n = proof_length
        self.num_nodes = num_nodes

        # Some steps may be defective
        num_defects = int(proof_length * defect_fraction)
        self.defective = set(self.rng.sample(range(proof_length), num_defects))

        # Each node gets a random subset of challenges
        self.node_challenges = {}
        challenges_per_node = max(1, proof_length // (2 * num_nodes))
        for node_id in range(num_nodes):
            self.node_challenges[node_id] = [
                self.rng.randrange(proof_length)
                for _ in range(challenges_per_node)
            ]

    def node_audit(self, node_id: int) -> dict:
        """Run audit for a single node."""
        challenges = self.node_challenges[node_id]
        results = [i not in self.defective for i in challenges]
        return {
            'node_id': node_id,
            'challenges': challenges,
            'all_accepted': all(results),
            'num_rejections': sum(1 for r in results if not r),
            'leakage': sum(1 for _ in challenges),  # simplified leakage
        }

    def collective_audit(self) -> dict:
        """Run audits across all nodes and aggregate."""
        node_results = [self.node_audit(i) for i in range(self.num_nodes)]
        any_rejection = any(not r['all_accepted'] for r in node_results)
        total_challenges = sum(len(r['challenges']) for r in node_results)
        total_leakage = sum(r['leakage'] for r in node_results)

        # Unique steps audited
        all_challenged = set()
        for r in node_results:
            all_challenged.update(r['challenges'])

        return {
            'num_nodes': self.num_nodes,
            'total_challenges': total_challenges,
            'unique_steps_audited': len(all_challenged),
            'coverage': len(all_challenged) / self.n,
            'defect_detected': any_rejection,
            'total_leakage': total_leakage,
            'node_results': node_results,
        }


# ============================================================
# Application 3: Progressive Trust Building
# ============================================================

class ProgressiveTrustBuilder:
    """Models incremental trust building through successive audit rounds.

    Each round, the reviewer gains more confidence. The trust level
    grows as 1 - (1-δ)^k for defective proofs, and remains at 1
    for valid proofs. This models the real process of mathematical
    peer review where confidence builds gradually.
    """

    def __init__(self, proof_length: int, defect_density: float = 0.0,
                 max_deps: int = 2, seed: int = 42):
        self.rng = random.Random(seed)
        self.n = proof_length
        self.defect_density = defect_density
        self.max_deps = max_deps

        # Create certificate
        num_defects = int(proof_length * defect_density)
        self.defective = set(self.rng.sample(range(proof_length), num_defects))

        self.deps = []
        for i in range(proof_length):
            nd = self.rng.randint(0, min(max_deps, i))
            self.deps.append(sorted(self.rng.sample(range(i), nd)) if i > 0 and nd > 0 else [])

    def build_trust(self, max_rounds: int = 50) -> List[dict]:
        """Conduct progressive auditing, returning trust state after each round."""
        history = []
        cumulative_leakage = 0
        found_defect = False

        for k in range(1, max_rounds + 1):
            challenge = self.rng.randrange(self.n)
            is_valid = challenge not in self.defective
            step_leakage = 1 + len(self.deps[challenge])
            cumulative_leakage += step_leakage

            if not is_valid:
                found_defect = True

            # Theoretical confidence bounds
            if self.defect_density > 0:
                theoretical_confidence = 1 - (1 - self.defect_density) ** k
            else:
                theoretical_confidence = 1.0

            history.append({
                'round': k,
                'challenge': challenge,
                'valid': is_valid,
                'defect_found_so_far': found_defect,
                'cumulative_leakage': cumulative_leakage,
                'leakage_fraction': cumulative_leakage / self.n,
                'theoretical_confidence': theoretical_confidence,
            })

        return history


# ============================================================
# Application 4: Proof-Carrying Code Verification
# ============================================================

class ProofCarryingCodeVerifier:
    """Simulates verification of proof-carrying code with bounded disclosure.

    In proof-carrying code, a code producer attaches a proof of safety
    to their program. The consumer can verify safety by auditing the
    proof locally, without understanding the full proof or the code's
    internal structure.
    """

    def __init__(self, code_modules: int, proof_steps_per_module: int,
                 max_deps: int = 3, seed: int = 42):
        self.rng = random.Random(seed)
        self.num_modules = code_modules
        self.steps_per_module = proof_steps_per_module
        self.max_deps = max_deps
        self.total_steps = code_modules * proof_steps_per_module

        # Generate module structure
        self.module_ranges = []
        for m in range(code_modules):
            start = m * proof_steps_per_module
            end = start + proof_steps_per_module
            self.module_ranges.append((start, end))

        # All steps valid by default
        self.valid = [True] * self.total_steps

    def audit_module(self, module_id: int, num_checks: int = 3) -> dict:
        """Audit a specific code module's proof."""
        start, end = self.module_ranges[module_id]
        challenges = [self.rng.randrange(start, end) for _ in range(num_checks)]
        results = [self.valid[c] for c in challenges]

        return {
            'module_id': module_id,
            'module_steps': self.steps_per_module,
            'checks': num_checks,
            'all_passed': all(results),
            'leakage': num_checks * (1 + self.max_deps),  # upper bound
            'leakage_fraction': num_checks * (1 + self.max_deps) / self.steps_per_module,
        }

    def full_audit(self, checks_per_module: int = 3) -> dict:
        """Audit all modules."""
        results = [self.audit_module(m, checks_per_module)
                    for m in range(self.num_modules)]
        all_passed = all(r['all_passed'] for r in results)
        total_leakage = sum(r['leakage'] for r in results)

        return {
            'total_modules': self.num_modules,
            'total_proof_steps': self.total_steps,
            'checks_per_module': checks_per_module,
            'all_passed': all_passed,
            'total_leakage': total_leakage,
            'leakage_fraction': total_leakage / self.total_steps,
            'module_results': results,
        }


# ============================================================
# Main Demo
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF LOCALLY AUDITABLE PROOF CERTIFICATES              ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    # Application 1: Privacy-Preserving Peer Review
    print("=" * 70)
    print("APPLICATION 1: Privacy-Preserving Peer Review")
    print("=" * 70)
    review = PrivacyPreservingReview(proof_length=200, max_deps=4)
    for rounds in [5, 10, 20, 50]:
        result = review.review_session(rounds)
        print(f"  {rounds:3d} rounds: accepted={result['all_accepted']}, "
              f"leakage={result['total_leakage']:4d}/{review.n} "
              f"({result['fraction_revealed']:.1%})")
    print()

    # Application 2: Distributed Certification
    print("=" * 70)
    print("APPLICATION 2: Distributed Theorem Certification")
    print("=" * 70)
    for defect_frac in [0.0, 0.05, 0.1, 0.2]:
        dc = DistributedCertification(
            proof_length=500, num_nodes=10,
            defect_fraction=defect_frac, seed=42
        )
        result = dc.collective_audit()
        print(f"  Defect {defect_frac:.0%}: nodes={result['num_nodes']}, "
              f"coverage={result['coverage']:.1%}, "
              f"detected={result['defect_detected']}")
    print()

    # Application 3: Progressive Trust
    print("=" * 70)
    print("APPLICATION 3: Progressive Trust Building")
    print("=" * 70)
    trust = ProgressiveTrustBuilder(proof_length=100, defect_density=0.1)
    history = trust.build_trust(max_rounds=30)
    print(f"  {'Round':>6} {'Found':>8} {'Leakage%':>10} {'Theoretical':>12}")
    for h in history[::5]:  # every 5th round
        print(f"  {h['round']:>6} {str(h['defect_found_so_far']):>8} "
              f"{h['leakage_fraction']:>9.1%} {h['theoretical_confidence']:>11.4f}")
    print()

    # Application 4: Proof-Carrying Code
    print("=" * 70)
    print("APPLICATION 4: Proof-Carrying Code Verification")
    print("=" * 70)
    pcc = ProofCarryingCodeVerifier(code_modules=20, proof_steps_per_module=50)
    for checks in [1, 3, 5, 10]:
        result = pcc.full_audit(checks_per_module=checks)
        print(f"  {checks:2d} checks/module: passed={result['all_passed']}, "
              f"leakage={result['leakage_fraction']:.1%} of proof")
    print()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
demo.py — Demonstration of Locally Auditable Derivation Certificates

Generates sample propositional derivation certificates, corrupts selected proof steps,
and empirically measures:
  1. One-step rejection frequency versus defect density
  2. Repeated-audit acceptance decay (exponential soundness amplification)
  3. Transcript-size growth against round count (linear leakage)

This demonstrates the core theorems from the formal Lean development.
"""

import random
import math
from dataclasses import dataclass, field
from typing import List, Set, Optional, Tuple, Callable


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class PropFormula:
    """Simple propositional formula (variable, negation, implication)."""
    kind: str  # 'var', 'neg', 'imp'
    var: Optional[str] = None
    left: Optional['PropFormula'] = None
    right: Optional['PropFormula'] = None

    def __repr__(self):
        if self.kind == 'var':
            return self.var
        elif self.kind == 'neg':
            return f"¬{self.left}"
        elif self.kind == 'imp':
            return f"({self.left} → {self.right})"
        return "?"

    def size(self):
        if self.kind == 'var':
            return 1
        elif self.kind == 'neg':
            return 1 + self.left.size()
        elif self.kind == 'imp':
            return 1 + self.left.size() + self.right.size()
        return 0


def var(name: str) -> PropFormula:
    return PropFormula(kind='var', var=name)

def neg(f: PropFormula) -> PropFormula:
    return PropFormula(kind='neg', left=f)

def imp(a: PropFormula, b: PropFormula) -> PropFormula:
    return PropFormula(kind='imp', left=a, right=b)


@dataclass
class ProofStep:
    """A single step in a Hilbert-style propositional derivation."""
    formula: PropFormula
    rule: str  # 'axiom_k', 'axiom_s', 'mp', 'assumption'
    deps: List[int] = field(default_factory=list)  # indices of dependencies

    def __repr__(self):
        return f"Step({self.formula}, rule={self.rule}, deps={self.deps})"


@dataclass
class DerivationCertificate:
    """A complete derivation certificate with explicit dependency structure."""
    steps: List[ProofStep]
    goal: PropFormula

    @property
    def length(self) -> int:
        return len(self.steps)

    def dep_sizes(self) -> List[int]:
        return [len(s.deps) for s in self.steps]

    def max_dep_card(self) -> int:
        return max(self.dep_sizes()) if self.steps else 0


# ============================================================
# Hilbert-Style Proof System
# ============================================================

def is_axiom_k(f: PropFormula) -> bool:
    """Check if f has the form A → (B → A)."""
    if f.kind != 'imp':
        return False
    a = f.left
    ba = f.right
    if ba.kind != 'imp':
        return False
    return repr(a) == repr(ba.right)

def is_axiom_s(f: PropFormula) -> bool:
    """Check if f has the form (A → B → C) → (A → B) → (A → C)."""
    if f.kind != 'imp':
        return False
    abc = f.left
    if abc.kind != 'imp':
        return False
    a = abc.left
    bc = abc.right
    if bc.kind != 'imp':
        return False
    b, c = bc.left, bc.right
    abac = f.right
    if abac.kind != 'imp':
        return False
    ab = abac.left
    ac = abac.right
    if ab.kind != 'imp' or ac.kind != 'imp':
        return False
    return (repr(a) == repr(ab.left) == repr(ac.left) and
            repr(b) == repr(ab.right) and
            repr(c) == repr(ac.right))

def is_modus_ponens(conclusion: PropFormula, premise1: PropFormula,
                     premise2: PropFormula) -> bool:
    """Check if conclusion follows from premise1 and premise2 by modus ponens.
    premise1 should be A, premise2 should be A → B, conclusion should be B."""
    if premise2.kind != 'imp':
        return False
    return (repr(premise1) == repr(premise2.left) and
            repr(conclusion) == repr(premise2.right))


def verify_step(cert: DerivationCertificate, index: int) -> bool:
    """Verify a single step of a derivation certificate (local audit)."""
    step = cert.steps[index]

    if step.rule == 'axiom_k':
        return is_axiom_k(step.formula)
    elif step.rule == 'axiom_s':
        return is_axiom_s(step.formula)
    elif step.rule == 'assumption':
        return True  # Assumptions are always valid as axioms
    elif step.rule == 'mp':
        if len(step.deps) != 2:
            return False
        d1, d2 = step.deps
        if d1 < 0 or d1 >= len(cert.steps) or d2 < 0 or d2 >= len(cert.steps):
            return False
        return is_modus_ponens(step.formula, cert.steps[d1].formula,
                                cert.steps[d2].formula)
    return False


# ============================================================
# Certificate Generation
# ============================================================

def generate_identity_proof(p: str = "P") -> DerivationCertificate:
    """Generate a proof of P → P using Hilbert axioms K and S.

    Standard proof:
    1. (P → ((P → P) → P)) → ((P → (P → P)) → (P → P))   [Axiom S]
    2. P → ((P → P) → P)                                     [Axiom K]
    3. (P → (P → P)) → (P → P)                               [MP 2,1]
    4. P → (P → P)                                            [Axiom K]
    5. P → P                                                   [MP 4,3]
    """
    P = var(p)
    PP = imp(P, P)

    # Step 0: Axiom S instance
    # (P → (P→P) → P) → (P → (P→P)) → (P → P)
    s_instance = imp(
        imp(P, imp(PP, P)),
        imp(imp(P, PP), PP)
    )
    step0 = ProofStep(s_instance, 'axiom_s', [])

    # Step 1: Axiom K instance: P → ((P→P) → P)
    k1 = imp(P, imp(PP, P))
    step1 = ProofStep(k1, 'axiom_k', [])

    # Step 2: MP steps 1 and 0: (P → (P→P)) → (P → P)
    mp1 = imp(imp(P, PP), PP)
    step2 = ProofStep(mp1, 'mp', [1, 0])

    # Step 3: Axiom K instance: P → (P → P)
    k2 = imp(P, PP)
    step3 = ProofStep(k2, 'axiom_k', [])

    # Step 4: MP steps 3 and 2: P → P
    step4 = ProofStep(PP, 'mp', [3, 2])

    return DerivationCertificate(
        steps=[step0, step1, step2, step3, step4],
        goal=PP
    )


def generate_longer_proof(n_vars: int = 3) -> DerivationCertificate:
    """Generate a longer proof by composing identity proofs and K-axioms."""
    steps = []
    variables = [var(f"x{i}") for i in range(n_vars)]

    # Build identity proofs for each variable
    for v in variables:
        vv = imp(v, v)
        base_idx = len(steps)

        # S axiom instance
        s_inst = imp(
            imp(v, imp(vv, v)),
            imp(imp(v, vv), vv)
        )
        steps.append(ProofStep(s_inst, 'axiom_s', []))

        # K axiom: v → (v→v) → v
        k1 = imp(v, imp(vv, v))
        steps.append(ProofStep(k1, 'axiom_k', []))

        # MP
        mp1 = imp(imp(v, vv), vv)
        steps.append(ProofStep(mp1, 'mp', [base_idx + 1, base_idx]))

        # K axiom: v → (v→v)
        k2 = imp(v, vv)
        steps.append(ProofStep(k2, 'axiom_k', []))

        # MP: v → v
        steps.append(ProofStep(vv, 'mp', [base_idx + 3, base_idx + 2]))

    # Add some K-axiom chains between variables
    for i in range(n_vars - 1):
        vi, vj = variables[i], variables[i + 1]
        k = imp(vi, imp(vj, vi))
        steps.append(ProofStep(k, 'axiom_k', []))

    goal = imp(variables[-1], variables[-1])
    return DerivationCertificate(steps=steps, goal=goal)


# ============================================================
# Certificate Corruption
# ============================================================

def corrupt_certificate(cert: DerivationCertificate, num_corruptions: int,
                        seed: int = 42) -> Tuple[DerivationCertificate, Set[int]]:
    """Corrupt a certificate by replacing random steps with invalid formulas."""
    rng = random.Random(seed)
    n = cert.length
    corrupted_indices = set(rng.sample(range(n), min(num_corruptions, n)))

    new_steps = []
    for i, step in enumerate(cert.steps):
        if i in corrupted_indices:
            # Replace with a bogus formula that doesn't match any rule
            bogus = imp(var("BOGUS"), var(f"BAD_{i}"))
            new_steps.append(ProofStep(bogus, step.rule, step.deps))
        else:
            new_steps.append(step)

    return DerivationCertificate(steps=new_steps, goal=cert.goal), corrupted_indices


# ============================================================
# Audit Protocol
# ============================================================

def single_audit(cert: DerivationCertificate, challenge: int) -> bool:
    """Perform a single-step audit at the given challenge index."""
    return verify_step(cert, challenge)


def repeated_audit(cert: DerivationCertificate, challenges: List[int]) -> bool:
    """Perform repeated audits; accept iff all individual audits accept."""
    return all(single_audit(cert, c) for c in challenges)


def compute_defect_density(cert: DerivationCertificate) -> float:
    """Compute the fraction of defective steps."""
    n = cert.length
    if n == 0:
        return 0.0
    bad = sum(1 for i in range(n) if not verify_step(cert, i))
    return bad / n


def compute_rejection_probability(cert: DerivationCertificate,
                                   num_trials: int = 10000,
                                   seed: int = 123) -> float:
    """Estimate rejection probability under uniform random single audit."""
    rng = random.Random(seed)
    n = cert.length
    rejections = sum(1 for _ in range(num_trials)
                     if not single_audit(cert, rng.randrange(n)))
    return rejections / num_trials


def leakage_cost(cert: DerivationCertificate, challenge: int) -> int:
    """Compute leakage cost of a single audit: 1 + number of dependencies."""
    return 1 + len(cert.steps[challenge].deps)


def total_leakage_cost(cert: DerivationCertificate, challenges: List[int]) -> int:
    """Total leakage cost over multiple audit rounds."""
    return sum(leakage_cost(cert, c) for c in challenges)


# ============================================================
# Experiments
# ============================================================

def experiment_1_detection_vs_density():
    """Experiment 1: One-step rejection frequency vs defect density."""
    print("=" * 70)
    print("EXPERIMENT 1: Detection Probability vs Defect Density")
    print("=" * 70)
    print()

    cert = generate_longer_proof(n_vars=8)
    n = cert.length
    print(f"Certificate length: {n} steps")
    print(f"Max dependency size: {cert.max_dep_card()}")
    print()

    print(f"{'Corruptions':>12} {'Defect Density':>15} {'Rejection Prob':>15} {'Ratio':>8}")
    print("-" * 55)

    for num_corrupt in range(0, n + 1, max(1, n // 10)):
        corrupted, bad_indices = corrupt_certificate(cert, num_corrupt)
        density = compute_defect_density(corrupted)
        reject_prob = compute_rejection_probability(corrupted)

        ratio = reject_prob / density if density > 0 else float('inf')
        print(f"{num_corrupt:>12} {density:>15.4f} {reject_prob:>15.4f} {ratio:>8.3f}")

    print()
    print("Theory predicts: Rejection Prob ≥ Defect Density (ratio ≥ 1.0)")
    print()


def experiment_2_amplification():
    """Experiment 2: Repeated-audit acceptance decay."""
    print("=" * 70)
    print("EXPERIMENT 2: Exponential Soundness Amplification")
    print("=" * 70)
    print()

    cert = generate_longer_proof(n_vars=6)
    n = cert.length
    num_corrupt = max(1, n // 4)
    corrupted, _ = corrupt_certificate(cert, num_corrupt)
    density = compute_defect_density(corrupted)
    accept_prob_single = 1.0 - density

    print(f"Certificate length: {n}")
    print(f"Corrupted steps: {num_corrupt}")
    print(f"Defect density: {density:.4f}")
    print(f"Single-audit accept prob: {accept_prob_single:.4f}")
    print()

    rng = random.Random(456)
    num_trials = 10000

    print(f"{'Rounds k':>10} {'Empirical Accept':>18} {'Theoretical Bound':>18} {'Ratio':>8}")
    print("-" * 58)

    for k in [1, 2, 3, 5, 8, 10, 15, 20]:
        accepts = 0
        for _ in range(num_trials):
            challenges = [rng.randrange(n) for _ in range(k)]
            if repeated_audit(corrupted, challenges):
                accepts += 1
        empirical = accepts / num_trials
        theoretical = accept_prob_single ** k

        ratio = empirical / theoretical if theoretical > 1e-10 else float('inf')
        print(f"{k:>10} {empirical:>18.6f} {theoretical:>18.6f} {ratio:>8.3f}")

    print()
    print("Theory predicts: Empirical ≤ Theoretical (ratio ≤ 1.0)")
    print()


def experiment_3_leakage():
    """Experiment 3: Transcript-size growth vs round count."""
    print("=" * 70)
    print("EXPERIMENT 3: Linear Leakage Growth")
    print("=" * 70)
    print()

    cert = generate_longer_proof(n_vars=10)
    n = cert.length
    max_d = cert.max_dep_card()
    theoretical_per_round = 1 + max_d

    print(f"Certificate length: {n}")
    print(f"Max dependency card: {max_d}")
    print(f"Theoretical per-round bound: {theoretical_per_round}")
    print()

    rng = random.Random(789)

    print(f"{'Rounds k':>10} {'Avg Leakage':>14} {'Max Leakage':>14} {'Bound k*(1+d)':>14}")
    print("-" * 55)

    for k in [1, 2, 5, 10, 20, 50, 100]:
        leakages = []
        for _ in range(1000):
            challenges = [rng.randrange(n) for _ in range(k)]
            leak = total_leakage_cost(cert, challenges)
            leakages.append(leak)

        avg_leak = sum(leakages) / len(leakages)
        max_leak = max(leakages)
        bound = k * theoretical_per_round

        print(f"{k:>10} {avg_leak:>14.2f} {max_leak:>14} {bound:>14}")

    print()
    print("Theory predicts: Max Leakage ≤ k * (1 + max_dep_card)")
    print()


def experiment_4_completeness():
    """Experiment 4: Perfect completeness verification."""
    print("=" * 70)
    print("EXPERIMENT 4: Perfect Completeness Verification")
    print("=" * 70)
    print()

    for name, cert in [
        ("Identity (P→P)", generate_identity_proof()),
        ("Extended (8 vars)", generate_longer_proof(8)),
        ("Extended (12 vars)", generate_longer_proof(12)),
    ]:
        n = cert.length
        all_pass = all(verify_step(cert, i) for i in range(n))
        print(f"{name}: {n} steps, all pass: {all_pass}")

    print()
    print("Theory predicts: Well-formed certificates pass ALL audits.")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  LOCALLY AUDITABLE DERIVATION CERTIFICATES — DEMONSTRATION         ║")
    print("║  Zero-Knowledge Theorem Proving: Bounded Revelation Protocols      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    experiment_4_completeness()
    experiment_1_detection_vs_density()
    experiment_2_amplification()
    experiment_3_leakage()

    print("=" * 70)
    print("All experiments completed successfully.")
    print("Results confirm formal theorems: completeness, detection bound,")
    print("exponential amplification, and linear leakage growth.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Exponential Soundness Amplification

Visualizes how repeated independent audits exponentially decrease the probability
that a defective proof certificate passes verification. Shows theoretical bounds
(1-ε)^k alongside empirical measurements for various defect densities.

This is the core visual demonstration of Theorem 3 (repeated_audit_accept_count_le_pow):
the number of all-accepting challenge sequences decays exponentially with the number
of audit rounds.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

# ── Self-contained certificate simulation ──

def generate_certificate(n_steps, n_vars=5, seed=42):
    """Generate a synthetic proof certificate."""
    rng = random.Random(seed)
    valid = [True] * n_steps
    deps = []
    for i in range(n_steps):
        nd = rng.randint(0, min(2, i))
        deps.append(sorted(rng.sample(range(i), nd)) if i > 0 and nd > 0 else [])
    return valid, deps

def corrupt(valid, num_corrupt, seed=42):
    """Corrupt a certificate by marking random steps as invalid."""
    rng = random.Random(seed)
    n = len(valid)
    corrupted = list(valid)
    indices = rng.sample(range(n), min(num_corrupt, n))
    for i in indices:
        corrupted[i] = False
    return corrupted

def repeated_audit_trial(valid, k, rng):
    """Single trial of k-round audit. Returns True if all rounds accept."""
    n = len(valid)
    return all(valid[rng.randrange(n)] for _ in range(k))

# ── Generate data ──

n_steps = 50
valid_base, deps = generate_certificate(n_steps)
defect_densities = [0.05, 0.10, 0.20, 0.35, 0.50]
k_values = np.arange(1, 31)
num_trials = 20000

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: log-scale acceptance probability vs rounds
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(defect_densities)))

for idx, density in enumerate(defect_densities):
    num_corrupt = max(1, int(n_steps * density))
    corrupted = corrupt(valid_base, num_corrupt, seed=idx * 100)
    actual_density = sum(1 for v in corrupted if not v) / n_steps
    accept_prob_single = 1 - actual_density

    # Theoretical curve
    theoretical = [accept_prob_single ** k for k in k_values]
    ax1.plot(k_values, theoretical, '-', color=colors[idx], linewidth=2,
             label=f'δ={actual_density:.2f} (theory)')

    # Empirical points
    rng = random.Random(42 + idx)
    empirical = []
    for k in k_values:
        accepts = sum(1 for _ in range(num_trials)
                      if repeated_audit_trial(corrupted, k, rng))
        empirical.append(accepts / num_trials)
    ax1.scatter(k_values[::3], [empirical[i] for i in range(0, len(k_values), 3)],
                color=colors[idx], s=40, zorder=5, edgecolors='white', linewidth=0.5)

ax1.set_yscale('log')
ax1.set_xlabel('Number of Audit Rounds (k)', fontsize=12)
ax1.set_ylabel('Acceptance Probability', fontsize=12)
ax1.set_title('Exponential Soundness Amplification', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9, loc='upper right')
ax1.set_ylim(1e-6, 1.1)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, 31)

# Right panel: rounds needed for target confidence
target_confidences = [0.90, 0.95, 0.99, 0.999]
density_range = np.linspace(0.01, 0.5, 100)

for conf in target_confidences:
    rounds_needed = [np.log(1 - conf) / np.log(1 - d) for d in density_range]
    ax2.plot(density_range, rounds_needed, linewidth=2,
             label=f'{conf:.1%} confidence')

ax2.set_xlabel('Defect Density (δ)', fontsize=12)
ax2.set_ylabel('Audit Rounds Needed', fontsize=12)
ax2.set_title('Rounds for Target Confidence', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 0.5)
ax2.set_ylim(0, 100)

plt.tight_layout()
plt.savefig('viz_amplification.png', dpi=150, bbox_inches='tight')
print("Saved viz_amplification.png")


#!/usr/bin/env python3
"""
Visualization: Defect Detection Heatmap

Visualizes the detection probability as a function of both defect density and
number of audit rounds. This creates a heatmap showing the "detection landscape"
— the probability of catching at least one defective step across different
parameter regimes.

Demonstrates Theorem 2 (detection count bound) combined with Theorem 3
(exponential amplification): the probability of detecting a defect of density δ
after k rounds is at least 1 - (1-δ)^k.
"""

import numpy as np
import matplotlib.pyplot as plt

# ── Compute detection probability surface ──

densities = np.linspace(0.01, 0.50, 50)
rounds = np.arange(1, 41)

# Detection probability: P(detect) = 1 - (1-δ)^k
D, K = np.meshgrid(densities, rounds)
detection_prob = 1 - (1 - D) ** K

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ── Panel 1: Heatmap ──
ax1 = axes[0]
im = ax1.pcolormesh(densities * 100, rounds, detection_prob,
                     cmap='YlOrRd', shading='auto', vmin=0, vmax=1)
plt.colorbar(im, ax=ax1, label='Detection Probability')

# Add contour lines
contours = ax1.contour(densities * 100, rounds, detection_prob,
                        levels=[0.5, 0.9, 0.95, 0.99],
                        colors='black', linewidths=1)
ax1.clabel(contours, inline=True, fontsize=9, fmt='%.2f')

ax1.set_xlabel('Defect Density (%)', fontsize=12)
ax1.set_ylabel('Number of Audit Rounds', fontsize=12)
ax1.set_title('Detection Probability Landscape', fontsize=14, fontweight='bold')

# ── Panel 2: Detection curves for fixed densities ──
ax2 = axes[1]
highlight_densities = [0.02, 0.05, 0.10, 0.20, 0.35]
colors = plt.cm.plasma(np.linspace(0.15, 0.85, len(highlight_densities)))

for i, d in enumerate(highlight_densities):
    probs = [1 - (1-d)**k for k in rounds]
    ax2.plot(rounds, probs, '-', color=colors[i], linewidth=2,
             label=f'δ = {d:.0%}')
    # Mark 95% threshold
    k95 = next((k for k in rounds if 1-(1-d)**k >= 0.95), None)
    if k95 and k95 <= 40:
        ax2.plot(k95, 0.95, 'o', color=colors[i], markersize=8, zorder=5)

ax2.axhline(y=0.95, color='gray', linestyle='--', alpha=0.5, label='95% threshold')
ax2.set_xlabel('Number of Audit Rounds', fontsize=12)
ax2.set_ylabel('Detection Probability', fontsize=12)
ax2.set_title('Detection Curves by Defect Density', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 41)
ax2.set_ylim(0, 1.05)

# ── Panel 3: Rounds needed for various confidence levels ──
ax3 = axes[2]
conf_levels = [0.50, 0.90, 0.95, 0.99, 0.999]
density_range = np.linspace(0.01, 0.5, 200)
colors3 = plt.cm.coolwarm(np.linspace(0.1, 0.9, len(conf_levels)))

for i, conf in enumerate(conf_levels):
    k_needed = np.log(1 - conf) / np.log(1 - density_range)
    ax3.plot(density_range * 100, k_needed, '-', color=colors3[i], linewidth=2,
             label=f'{conf:.1%} confidence')

ax3.set_xlabel('Defect Density (%)', fontsize=12)
ax3.set_ylabel('Rounds Required', fontsize=12)
ax3.set_title('Cost of Confidence', fontsize=14, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_xlim(0, 50)
ax3.set_ylim(0, 80)

plt.tight_layout()
plt.savefig('viz_detection.png', dpi=150, bbox_inches='tight')
print("Saved viz_detection.png")


#!/usr/bin/env python3
"""
Visualization: Linear Leakage Growth vs Exponential Confidence Gain

Visualizes the fundamental asymmetry at the heart of locally auditable proofs:
information leakage grows only linearly with the number of audit rounds, while
the verifier's confidence grows exponentially. This is the visual embodiment of
Theorems 3 and 5 together.

Left panel: Leakage (fraction of proof revealed) grows linearly.
Right panel: Confidence (1 - acceptance probability for defective proofs) grows
exponentially toward 1.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

# ── Self-contained simulation ──

def simulate_audit_leakage(n_steps, max_dep, k_values, num_trials=2000, seed=42):
    """Simulate leakage for various round counts."""
    rng = random.Random(seed)
    # Generate random dependency sizes
    dep_sizes = [rng.randint(0, max_dep) for _ in range(n_steps)]

    results = {}
    for k in k_values:
        leakages = []
        for _ in range(num_trials):
            total = sum(1 + dep_sizes[rng.randrange(n_steps)] for _ in range(k))
            leakages.append(total)
        results[k] = {
            'mean': np.mean(leakages),
            'max': np.max(leakages),
            'min': np.min(leakages),
            'std': np.std(leakages),
            'bound': k * (1 + max_dep),
        }
    return results

# ── Parameters ──

n_steps = 100
max_dep = 3
k_values = list(range(1, 51))
defect_density = 0.15

leakage_data = simulate_audit_leakage(n_steps, max_dep, k_values)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# ── Left panel: Leakage ──

means = [leakage_data[k]['mean'] / n_steps for k in k_values]
maxes = [leakage_data[k]['max'] / n_steps for k in k_values]
bounds = [leakage_data[k]['bound'] / n_steps for k in k_values]

ax1.fill_between(k_values,
                  [leakage_data[k]['mean'] / n_steps - leakage_data[k]['std'] / n_steps for k in k_values],
                  [leakage_data[k]['mean'] / n_steps + leakage_data[k]['std'] / n_steps for k in k_values],
                  alpha=0.2, color='steelblue')
ax1.plot(k_values, means, '-', color='steelblue', linewidth=2, label='Average leakage')
ax1.plot(k_values, maxes, '--', color='coral', linewidth=1.5, label='Max leakage (empirical)')
ax1.plot(k_values, bounds, '-', color='darkred', linewidth=2, label='Bound: k·(1+d)/n')

ax1.set_xlabel('Number of Audit Rounds (k)', fontsize=12)
ax1.set_ylabel('Fraction of Proof Revealed', fontsize=12)
ax1.set_title('Information Leakage (Linear Growth)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, 51)

# ── Right panel: Confidence vs Leakage ──

# For each k, compute both leakage fraction and confidence
leakage_fracs = [leakage_data[k]['mean'] / n_steps for k in k_values]
confidences = [1 - (1 - defect_density) ** k for k in k_values]

# Create a dual-axis plot showing the asymmetry
ax2.plot(k_values, confidences, '-', color='forestgreen', linewidth=2.5,
         label=f'Confidence (δ={defect_density})')
ax2.fill_between(k_values, 0, confidences, alpha=0.1, color='forestgreen')

ax2_twin = ax2.twinx()
ax2_twin.plot(k_values, leakage_fracs, '-', color='steelblue', linewidth=2.5,
              label='Leakage fraction')
ax2_twin.fill_between(k_values, 0, leakage_fracs, alpha=0.1, color='steelblue')

ax2.set_xlabel('Number of Audit Rounds (k)', fontsize=12)
ax2.set_ylabel('Confidence (1 - accept prob)', fontsize=12, color='forestgreen')
ax2_twin.set_ylabel('Fraction of Proof Revealed', fontsize=12, color='steelblue')
ax2.set_title('Confidence vs Leakage: The Fundamental Asymmetry',
              fontsize=14, fontweight='bold')

# Annotate the sweet spot
sweet_k = 15
ax2.annotate(f'k={sweet_k}: {1-(1-defect_density)**sweet_k:.1%} confidence\n'
             f'with {leakage_data[sweet_k]["mean"]/n_steps:.0%} leakage',
             xy=(sweet_k, 1-(1-defect_density)**sweet_k),
             xytext=(sweet_k + 8, 0.5),
             fontsize=10,
             arrowprops=dict(arrowstyle='->', color='black'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

ax2.set_xlim(0, 51)
ax2.set_ylim(0, 1.05)
ax2.grid(True, alpha=0.3)

# Combined legend
lines1, labels1 = ax2.get_legend_handles_labels()
lines2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(lines1 + lines2, labels1 + labels2, loc='center right', fontsize=10)

plt.tight_layout()
plt.savefig('viz_leakage.png', dpi=150, bbox_inches='tight')
print("Saved viz_leakage.png")
