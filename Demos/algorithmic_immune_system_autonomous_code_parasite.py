"""Algorithm 1 — Structural attestation: injective Gödel tagging and verification.

The monitor's only primitive.  A syntax tree is folded, in one post-order pass,
into a single natural number whose residue mod 5 records the head constructor and
whose quotient packs the children through a pairing bijection.  Because pairing
is injective and the residues separate the constructors, the tag determines the
tree uniquely: tag equality IS program equality.  Verification is therefore an
exact membership test against the sanctioned set, with no possibility of a
collision and hence no forgeable attestation.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, FrozenSet, Optional, Tuple


@dataclass(frozen=True)
class PAst:
    """inp | attack | lit n | ite(c,a,b) | call(f,a)."""

    kind: str
    num: int = 0
    kids: Tuple["PAst", ...] = ()


def pair(a: int, b: int) -> int:
    """A bijection N^2 -> N (the 'max-square' pairing)."""
    return a * a + a + b if a >= b else b * b + a


def unpair(z: int) -> Tuple[int, int]:
    """Inverse of ``pair``; used to prove tags are decodable, hence injective."""
    s = int(z ** 0.5)
    while (s + 1) * (s + 1) <= z:
        s += 1
    while s * s > z:
        s -= 1
    r = z - s * s
    return (r, s) if r < s else (s, r - s)  # the unique (a, b) with pair(a, b) == z


def code(t: PAst) -> int:
    """Attestation tag.  Single post-order traversal, Theta(size) operations."""
    if t.kind == "inp":
        return 0
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return 5 * t.num + 2
    if t.kind == "ite":
        c, a, b = t.kids
        return 5 * pair(pair(code(c), code(a)), code(b)) + 3
    f, a = t.kids
    return 5 * pair(code(f), code(a)) + 4


def decode(tag: int) -> PAst:
    """Reconstruct the unique program with the given tag (a proof of injectivity)."""
    if tag == 0:
        return PAst("inp")
    if tag == 1:
        return PAst("attack")
    head, payload = tag % 5, tag // 5
    if head == 2:
        return PAst("lit", num=payload)
    if head == 3:
        ca, b = unpair(payload)
        c, a = unpair(ca)
        return PAst("ite", kids=(decode(c), decode(a), decode(b)))
    f, a = unpair(payload)
    return PAst("call", kids=(decode(f), decode(a)))


class AttestationMonitor:
    """A sanctioned set stored as a tag table; verification is O(1) per check."""

    def __init__(self, sanctioned: FrozenSet[PAst]) -> None:
        self.table: Dict[int, PAst] = {code(t): t for t in sanctioned}

    def verify(self, t: PAst) -> bool:
        """True iff ``t`` is sanctioned.  Collision-free, so exactly membership."""
        return code(t) in self.table

    def witness(self, t: PAst) -> Optional[PAst]:
        """The stored variant matching ``t``; equals ``t`` itself when verified."""
        return self.table.get(code(t))


if __name__ == "__main__":
    inp, atk = PAst("inp"), PAst("attack")
    lit = lambda n: PAst("lit", num=n)
    ite = lambda c, a, b: PAst("ite", kids=(c, a, b))
    call = lambda f, a: PAst("call", kids=(f, a))

    samples = [inp, atk, lit(0), lit(9), ite(lit(0), atk, lit(3)), call(lit(2), inp)]
    tags = [code(t) for t in samples]
    print("tags               :", tags)
    print("all distinct       :", len(set(tags)) == len(tags))
    print("decode(code(t))==t :", all(decode(code(t)) == t for t in samples))

    mon = AttestationMonitor(frozenset({lit(0), lit(5)}))
    print("verify lit 0       :", mon.verify(lit(0)))
    print("verify ATTACK      :", mon.verify(atk))


"""Algorithm 2 — The guarded execution loop: quarantine, alarm and rollback.

The complete immune system.  Each step the (arbitrary, unknown, adaptive)
self-modification rewrites the running program; the monitor recomputes the
attestation tag, looks it up, and either accepts the mutant or restores the
trusted baseline in the same step.

Guarantees, independent of the adversary:
  * containment      — the running program is sanctioned at every step;
  * neutralization   — if every sanctioned program is harmless, the forbidden
                       action is never executed, ever;
  * alarm completeness — the alarm fires at a step exactly when that step's
                       mutation left the sanctioned set (no misses, no false
                       alarms);
  * transparency     — a mutation that stays inside the sanctioned set is
                       accepted verbatim, so legitimate updates see no monitor.

Cost per step: one tagging pass, Theta(size), plus one O(1) hash lookup.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Callable, FrozenSet, List, Set, Tuple


@dataclass(frozen=True)
class PAst:
    kind: str
    num: int = 0
    kids: Tuple["PAst", ...] = ()


def pair(a: int, b: int) -> int:
    return a * a + a + b if a >= b else b * b + a


def code(t: PAst) -> int:
    if t.kind == "inp":
        return 0
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return 5 * t.num + 2
    if t.kind == "ite":
        c, a, b = t.kids
        return 5 * pair(pair(code(c), code(a)), code(b)) + 3
    f, a = t.kids
    return 5 * pair(code(f), code(a)) + 4


def ev(t: PAst, x: int) -> int:
    if t.kind == "inp":
        return x
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return t.num
    if t.kind == "ite":
        c, a, b = t.kids
        return ev(a, x) if ev(c, x) != 0 else ev(b, x)
    f, a = t.kids
    return ev(f, ev(a, x))


def eff(t: PAst, x: int) -> bool:
    if t.kind in ("inp", "lit"):
        return False
    if t.kind == "attack":
        return True
    if t.kind == "ite":
        c, a, b = t.kids
        return eff(c, x) or (eff(a, x) if ev(c, x) != 0 else eff(b, x))
    f, a = t.kids
    return eff(a, x) or eff(f, ev(a, x))


def run(t: PAst) -> bool:
    """Self-execution: a program is executed on its own attestation tag."""
    return eff(t, code(t))


Adversary = Callable[[int, PAst], PAst]


@dataclass
class StepReport:
    step: int
    proposed: PAst
    accepted: PAst
    alarm: bool
    sanctioned: bool
    fired_forbidden_action: bool


@dataclass
class ImmuneRuntime:
    """A structural attestation monitor with same-step rollback."""

    sanctioned: FrozenSet[PAst]
    baseline: PAst
    current: PAst = field(init=False)
    tags: Set[int] = field(init=False)
    log: List[StepReport] = field(default_factory=list, init=False)

    def __post_init__(self) -> None:
        if self.baseline not in self.sanctioned:
            raise ValueError("the trusted baseline must itself be sanctioned")
        self.tags = {code(t) for t in self.sanctioned}
        self.current = self.baseline

    def verify(self, t: PAst) -> bool:
        """Collision-free tag lookup; equivalent to genuine set membership."""
        return code(t) in self.tags

    def step(self, n: int, adv: Adversary) -> StepReport:
        proposed = adv(n, self.current)
        alarm = not self.verify(proposed)
        self.current = self.baseline if alarm else proposed   # quarantine
        rep = StepReport(n, proposed, self.current, alarm,
                         self.current in self.sanctioned, run(self.current))
        self.log.append(rep)
        return rep

    def execute(self, adv: Adversary, steps: int) -> List[StepReport]:
        return [self.step(n, adv) for n in range(steps)]

    def contained(self) -> bool:
        return all(r.sanctioned for r in self.log)

    def neutralized(self) -> bool:
        return not any(r.fired_forbidden_action for r in self.log)


if __name__ == "__main__":
    lit = lambda n: PAst("lit", num=n)
    ite = lambda c, a, b: PAst("ite", kids=(c, a, b))
    attack = PAst("attack")

    S = frozenset({lit(0), lit(5)})

    def adversary(n: int, t: PAst) -> PAst:
        """Splice in the forbidden action on even steps, patch legitimately on odd."""
        return ite(lit(1), attack, t) if n % 2 == 0 else lit(5)

    rt = ImmuneRuntime(sanctioned=S, baseline=lit(0))
    for rep in rt.execute(adversary, 8):
        print(f"step {rep.step}: alarm={rep.alarm!s:<5} "
              f"sanctioned={rep.sanctioned!s:<5} "
              f"forbidden action fired={rep.fired_forbidden_action}")
    print("containment  :", rt.contained())
    print("neutralization:", rt.neutralized())
    print("unguarded, step 0 would have fired:", run(adversary(0, lit(0))))


"""Algorithm 3 — Diagonal parasite synthesis: turning any detector into its own
certified failure.

Input: the source of a harmless detector d, and a number n of padding bits.
Output: a program that d is provably wrong about.

    parasite(d, l)  =  if call(d, self) then pad(l) else attack

Since consulting a harmless detector has no observable effect, and since the
runtime executes a program on its own attestation tag, the program's effect is
exactly the branch chosen by d's verdict ABOUT THIS PROGRAM.  Hence the diagonal
identity

    parasite(d, l) is malicious   <=>   d does NOT flag parasite(d, l),

so d errs on it whichever way it answers: a sound d misses a real attack, a
complete d raises a false alarm on a harmless program.

The padding branch is never executed, so any bit string may be hidden there: the
2^n choices give 2^n distinct programs of size |d| + 3n + 5, all with the same
behaviour.  Evasion therefore has exponential density in program size.

Complexity: Theta(|d| + n) to emit one parasite; Theta(2^n (|d| + n)) for the
whole escape family.  Used as a red-team tool, it converts any deployed detector
into a certified counterexample.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterator, List, Sequence, Tuple


@dataclass(frozen=True)
class PAst:
    kind: str
    num: int = 0
    kids: Tuple["PAst", ...] = ()


INP, ATTACK = PAst("inp"), PAst("attack")
lit = lambda n: PAst("lit", num=n)
ite = lambda c, a, b: PAst("ite", kids=(c, a, b))
call = lambda f, a: PAst("call", kids=(f, a))


def size(t: PAst) -> int:
    return 1 if t.kind in ("inp", "attack", "lit") else 1 + sum(size(k) for k in t.kids)


def pair(a: int, b: int) -> int:
    return a * a + a + b if a >= b else b * b + a


def code(t: PAst) -> int:
    if t.kind == "inp":
        return 0
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return 5 * t.num + 2
    if t.kind == "ite":
        c, a, b = t.kids
        return 5 * pair(pair(code(c), code(a)), code(b)) + 3
    f, a = t.kids
    return 5 * pair(code(f), code(a)) + 4


def ev(t: PAst, x: int) -> int:
    if t.kind == "inp":
        return x
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return t.num
    if t.kind == "ite":
        c, a, b = t.kids
        return ev(a, x) if ev(c, x) != 0 else ev(b, x)
    f, a = t.kids
    return ev(f, ev(a, x))


def eff(t: PAst, x: int) -> bool:
    if t.kind in ("inp", "lit"):
        return False
    if t.kind == "attack":
        return True
    if t.kind == "ite":
        c, a, b = t.kids
        return eff(c, x) or (eff(a, x) if ev(c, x) != 0 else eff(b, x))
    f, a = t.kids
    return eff(a, x) or eff(f, ev(a, x))


def malicious(t: PAst) -> bool:
    return eff(t, code(t))


def flags(d: PAst, t: PAst) -> bool:
    return ev(d, code(t)) != 0


def is_harmless(d: PAst, samples: Sequence[int] = tuple(range(64))) -> bool:
    return not any(eff(d, x) for x in samples)


def pad(bits: Sequence[int]) -> PAst:
    """Behaviourally inert code carrying a bit string: computes 0, no effect."""
    t = lit(0)
    for b in reversed(bits):
        t = ite(lit(0), lit(1 if b else 0), t)
    return t


def synthesize(d: PAst, bits: Sequence[int] = ()) -> PAst:
    """The diagonal parasite of ``d`` carrying ``bits`` of dead code."""
    return ite(call(d, INP), pad(bits), ATTACK)


def escape_family(d: PAst, n: int) -> Iterator[PAst]:
    """All 2^n parasites of ``d`` with n padding bits."""
    for bits in product((0, 1), repeat=n):
        yield synthesize(d, bits)


def audit_detector(d: PAst, n: int = 6) -> dict:
    """Certify how ``d`` fails: report the witness and the escape statistics."""
    if not is_harmless(d):
        raise ValueError("the detector must itself be harmless")
    witness = synthesize(d)
    family = list(escape_family(d, n))
    identity_ok = all(malicious(p) == (not flags(d, p)) for p in family)
    return {
        "witness_size": size(witness),
        "witness_malicious": malicious(witness),
        "witness_flagged": flags(d, witness),
        "failure_mode": "missed attack" if malicious(witness) else "false alarm",
        "family_size": len(family),
        "expected_family_size": 2 ** n,
        "max_family_size_nodes": max(size(p) for p in family),
        "size_formula": size(d) + 3 * n + 5,
        "distinct_tags": len({code(p) for p in family}),
        "diagonal_identity_holds": identity_ok,
    }


if __name__ == "__main__":
    for name, d in (("silent   (sound, never accuses)", lit(0)),
                    ("paranoid (complete, always accuses)", lit(1))):
        print(f"\n=== detector: {name} ===")
        for k, v in audit_detector(d, n=6).items():
            print(f"  {k:<26} {v}")


"""Algorithm 4 — The uncertainty audit: measuring a monitor's memory and rigidity.

The immune uncertainty principle states that for every whitelist S and every n,

        2^n  <=  |S|              +   |P_n \\ S|
                 ^^^ memory            ^^^ rigidity

where P_n is the family of 2^n behaviourally trivial programs of size 3n+1 built
by nesting `if 0 then b else ...` with one bit b per level.  Every member of P_n
computes 0 and has no effect; they are pairwise distinct as syntax and pairwise
indistinguishable as behaviour.  A monitor must therefore either store them or
reject them, and this procedure measures which.

The audit is a deployable diagnostic: it reports how much of a monitor's budget
is spent on remembering variants versus on rejecting provably harmless code, and
how far the monitor sits above the theoretical floor.

Complexity: Theta(2^n * n) tag computations and membership tests.
Also included: the bounded-universe whitelist builder, which achieves perfect
immunity (total containment and zero false positives) up to a size bound N, and
whose memory is therefore at least 2^floor((N-1)/3).
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Dict, FrozenSet, List, Sequence, Tuple


@dataclass(frozen=True)
class PAst:
    kind: str
    num: int = 0
    kids: Tuple["PAst", ...] = ()


INP, ATTACK = PAst("inp"), PAst("attack")
lit = lambda n: PAst("lit", num=n)
ite = lambda c, a, b: PAst("ite", kids=(c, a, b))
call = lambda f, a: PAst("call", kids=(f, a))


def size(t: PAst) -> int:
    return 1 if t.kind in ("inp", "attack", "lit") else 1 + sum(size(k) for k in t.kids)


def pair(a: int, b: int) -> int:
    return a * a + a + b if a >= b else b * b + a


def code(t: PAst) -> int:
    if t.kind == "inp":
        return 0
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return 5 * t.num + 2
    if t.kind == "ite":
        c, a, b = t.kids
        return 5 * pair(pair(code(c), code(a)), code(b)) + 3
    f, a = t.kids
    return 5 * pair(code(f), code(a)) + 4


def ev(t: PAst, x: int) -> int:
    if t.kind == "inp":
        return x
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return t.num
    if t.kind == "ite":
        c, a, b = t.kids
        return ev(a, x) if ev(c, x) != 0 else ev(b, x)
    f, a = t.kids
    return ev(f, ev(a, x))


def eff(t: PAst, x: int) -> bool:
    if t.kind in ("inp", "lit"):
        return False
    if t.kind == "attack":
        return True
    if t.kind == "ite":
        c, a, b = t.kids
        return eff(c, x) or (eff(a, x) if ev(c, x) != 0 else eff(b, x))
    f, a = t.kids
    return eff(a, x) or eff(f, ev(a, x))


def run(t: PAst) -> bool:
    return eff(t, code(t))


def pad(bits: Sequence[int]) -> PAst:
    t = lit(0)
    for b in reversed(bits):
        t = ite(lit(0), lit(1 if b else 0), t)
    return t


def pad_family(n: int) -> List[PAst]:
    """P_n: 2^n behaviourally trivial programs, each of size 3n+1."""
    return [pad(bits) for bits in product((0, 1), repeat=n)]


def uncertainty_audit(S: FrozenSet[PAst], n: int) -> Dict[str, object]:
    """Measure memory, rigidity, and the slack above the exponential floor."""
    family = pad_family(n)
    tags = {code(t) for t in S}
    stored = sum(1 for t in family if code(t) in tags)
    rigidity = len(family) - stored
    floor = 2 ** n
    return {
        "n": n,
        "class_size": len(family),
        "member_size": 3 * n + 1,
        "memory_total": len(S),
        "memory_spent_on_class": stored,
        "rigidity": rigidity,
        "memory_plus_rigidity": len(S) + rigidity,
        "floor_2^n": floor,
        "slack": len(S) + rigidity - floor,
        "bound_satisfied": len(S) + rigidity >= floor,
        "entropy_bits_required_if_permissive": n if stored == len(family) else None,
    }


def bounded_universe(N: int, L: int) -> List[PAst]:
    """Every program of size <= N whose literals are < L (a finite set)."""
    by_size: Dict[int, List[PAst]] = {1: [INP, ATTACK] + [lit(i) for i in range(L)]}
    for s in range(2, N + 1):
        cur: List[PAst] = []
        for sf in range(1, s - 1):
            for f in by_size.get(sf, []):
                for a in by_size.get(s - 1 - sf, []):
                    cur.append(call(f, a))
        for sc in range(1, s - 1):
            for sa in range(1, s - sc - 1):
                sb = s - 1 - sc - sa
                if sb >= 1:
                    for c in by_size.get(sc, []):
                        for a in by_size.get(sa, []):
                            for b in by_size.get(sb, []):
                                cur.append(ite(c, a, b))
        by_size[s] = cur
    return [t for s in range(1, N + 1) for t in by_size.get(s, [])]


def bounded_whitelist(N: int, L: int) -> FrozenSet[PAst]:
    """Perfect immunity on a bounded universe: keep exactly the harmless programs."""
    return frozenset(t for t in bounded_universe(N, L) if not run(t))


if __name__ == "__main__":
    n = 7
    family = pad_family(n)
    print(f"class P_{n}: {len(family)} programs of size {size(family[0])}, "
          f"{len({code(t) for t in family})} distinct tags, "
          f"all behaviourally the constant 0.\n")
    for kept in (0, 32, 64, 128):
        S = frozenset(family[:kept])
        rep = uncertainty_audit(S, n)
        print(f"  store {kept:>3}: memory={rep['memory_total']:>3} "
              f"rigidity={rep['rigidity']:>3} sum={rep['memory_plus_rigidity']:>3} "
              f"floor={rep['floor_2^n']:>3} slack={rep['slack']:>2} "
              f"ok={rep['bound_satisfied']}")

    print("\nbounded universes (L = 2):")
    for N in range(1, 8):
        W = bounded_whitelist(N, 2)
        floor_exp = max([k for k in range(0, N) if 3 * k + 1 <= N], default=0)
        print(f"  N={N}: |whitelist|={len(W):>5}   memory floor 2^{floor_exp} = "
              f"{2 ** floor_exp:>4}   satisfied={len(W) >= 2 ** floor_exp}")


"""Assemble PACKAGE.json from the deliverable sources in the repository."""

from __future__ import annotations

import json
import os
from typing import Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
A = os.path.join(ROOT, "assets")


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


LEAN_FILES: List[str] = [
    "Catalog/Shared/ImmuneAstCore.lean",
    "Catalog/Shared/ImmuneSemantics.lean",
    "Catalog/Shared/ImmuneDetection.lean",
    "Catalog/Shared/ImmuneQuarantine.lean",
    "Catalog/Shared/ImmuneOracle.lean",
    "Catalog/Shared/ImmuneAlgebra.lean",
    "Catalog/Shared/ImmuneEnsemble.lean",
    "Catalog/Shared/ImmuneBounded.lean",
    "Catalog/Shared/ImmuneSampling.lean",
    "Catalog/Shared/ImmuneLabNotes.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== FILE: {p} =====\n\n{read(os.path.join(ROOT, p))}" for p in LEAN_FILES
)

FUTURE_DIRECTIONS = r"""# FUTURE DIRECTIONS — Algorithmic Immune Systems

Derived from the verified results of Parts I–IX: parasite calculus and
attestation, semantics, the diagonal parasite, quarantine and the conservation
law, the reflexive oracle barrier, the algebra of mutations and the immune
uncertainty principle, ensembles and the arms race, bounded universes, and
monitoring frequency.

Each conjecture below is stated so that it can be *falsified* by a single
explicit counterexample.

---

## Conjecture 1 (Immune capacity law: rigidity × memory is exactly exponential)

For every monitor `S` and every size bound `N`, let `mem(S) = |S|` and let
`rig(S, N)` be the number of behaviourally trivial programs of size `≤ N` that
`S` rejects. Then there are absolute constants `c₁, c₂ > 0` with

`c₁ · 2^{N/3} ≤ mem(S) + rig(S, N) ≤ c₂ · 2^{N/3} · poly(N)` for every *optimal*
monitor, and the lower bound is attained only by the bounded whitelist of
Part VIII.

*Status.* The lower bound `2^n ≤ |S| + |P_n \ S|` is **proved** (the immune
uncertainty principle); the matching upper bound and the uniqueness of the
optimum are open.

**The key insight is** that the padding construction realises an *injective
encoding of bit strings into a single semantic equivalence class*, so the immune
system is forced to pay one bit of memory per bit of dead code it wishes to
tolerate — attestation is a lossless code for a class on which behaviour is
constant.

**Why now?** Both sides are finitary and decidable for fixed `N`: the upper bound
is a counting argument over the bounded code universe, which is already
constructed and proved to contain every program of size `≤ N`.

---

## Conjecture 2 (Reflexive oracle hierarchy)

Stratify programs by *reflexion depth*: query-free programs have depth `0`, and a
program has depth `≤ d+1` if every oracle query it makes is answered by an oracle
that is correct on all programs of depth `≤ d`. Then for every `d` there is an
oracle `O_d` correct on all programs of depth `≤ d`, no oracle is correct at
depth `d+1` for all `d` simultaneously, and the hierarchy is strict.

*Status.* Depth `0` is **proved** (a perfect oracle exists for programs that never
consult it), and the global impossibility is **proved** (no oracle whatsoever is
correct once programs may query it). The strictness of the intermediate levels is
open.

**The key insight is** that oracle-independence of query-free behaviour is the
base case of an induction on reflexion depth: each level fixes the semantics of
the level below, exactly as a Tarskian truth hierarchy escapes the liar by
stratification.

**Why now?** The oracle-parameterised semantics is already in place, so a depth
predicate is a routine inductive definition on the reflexive syntax, and the
level-`d` oracle can be defined by the same classical comprehension used for the
canonical oracle.

---

## Conjecture 3 (No probabilistic escape from the diagonal)

Let `μ` be any finitely supported probability distribution over harmless
detectors, and let the monitor sample a detector `d ∼ μ` at runtime, so that a
parasite cannot know in advance which analyser it will face. Conjecture: for
every such `μ` there is a program that is malicious with probability at least
`1/2` and flagged with probability at most `1/2`. Randomisation therefore buys at
most a constant factor and never a guarantee.

*Status.* Open. The deterministic case is **proved** (the diagonal identity), and
finite support means the adversary can diagonalise against the disjunctive
ensemble of the support and then rebalance.

**The key insight is** that the ensemble theorem already shows a single program
defeats every member of a finite committee simultaneously; a probabilistic
monitor is such a committee equipped with weights, and the escaping program is
insensitive to the weights.

---

## Conjecture 4 (Graded effects and quantitative containment)

Replace the single forbidden action by a lattice of effects with costs. Does the
conservation law — containment, exponential rigidity, irreducibility — become a
quantitative trade-off between admitted risk and whitelist size, with the
uncertainty principle deformed into a weighted inequality?

---

## Conjecture 5 (Approximate attestation)

Replace exact tag equality by a similarity metric on syntax trees. Faithfulness
of attestation fails by design in that setting. At what exact rate does
containment degrade as a function of the metric's tolerance, and does an
uncertainty principle survive in the form "tolerance × memory ≥ exponential"?
"""

INTERACTIVE_LAYOUT = r"""# Algorithmic Immune Systems: A Guided Tour

*Can a program be protected from itself?*

Suppose you must guard a machine that rewrites its own source code at every tick
of the clock. You never get to see the rewrite rule; it may depend on the clock,
on the current program, and on your own monitoring policy. Your only obligation
is that the machine must never perform one designated forbidden action.

This page builds, from scratch, the complete answer: **you cannot win by
understanding the code, you can always win by recognising it, and recognition
costs exactly an exponential.** Every claim below is accompanied by something you
can run.

---

## 1. A world with exactly three dangerous ideas

Strip a programming language down to the features that make self-modifying
malware possible and five constructs remain:

- $\mathrm{lit}\,n$ — a numeric constant;
- $\mathrm{ite}(c,a,b)$ — branch on whether $c$ evaluates to something nonzero;
- $\mathrm{call}(f,a)$ — invoke the subprogram $f$ on the value produced by $a$;
- $\mathrm{attack}$ — the single observable forbidden action;
- $\mathrm{inp}$ — the **self register**.

The last one is the interesting one. Every program is executed on a number, and
that number is *its own source code*, encoded as an integer. A program can read
itself, reason about itself, and branch on what it finds.

<details>
<summary><strong>How a syntax tree becomes a number (and why it matters)</strong></summary>

Fix the standard pairing bijection $\langle\cdot,\cdot\rangle$ between pairs of
naturals and naturals, and define the *attestation tag*

$$\mathrm{code}(\mathrm{inp}) = 0,\quad \mathrm{code}(\mathrm{attack}) = 1,\quad
\mathrm{code}(\mathrm{lit}\,n) = 5n+2,$$
$$\mathrm{code}(\mathrm{ite}(c,a,b)) = 5\langle\langle c',a'\rangle,b'\rangle + 3,
\qquad \mathrm{code}(\mathrm{call}(f,a)) = 5\langle f',a'\rangle + 4,$$

where $c', a', b', f'$ are the tags of the children. The residue modulo $5$
records which construct sits at the root; the quotient packs the children.

**Faithfulness of Attestation.** *Distinct programs have distinct tags:
$\mathrm{code}(s) = \mathrm{code}(t)$ exactly when $s = t$.*

*Proof.* Induction. If the head constructors differ, the tags differ mod $5$. If
they agree, cancel the constant and the factor $5$, apply injectivity of pairing
to recover the children's tags, and appeal to the induction hypotheses. $\square$

This is the licence for everything positive that follows: comparing fingerprints
*is* comparing programs, with no possibility of a collision. The first algorithm
below even decodes a tag back into the unique program it came from.

</details>

Two semantic layers ride on top: the **value** a program computes, and its
**effect** — a single bit recording whether the forbidden action is *actually
executed*. Only the branch really taken contributes, so dead code is genuinely
dead. A program is **malicious** when running it on its own tag fires the action.

{{algorithm:0}}

---

## 2. The good news: detection is easy without self-reference

If a program never reads its self register, then an easy induction shows its
value and its effect are the same for every input.

> **The Static Scanner Is Perfect on Non-Quining Code.** For every
> self-reference-free program $t$, executing $t$ symbolically on the neutral
> input $0$ returns *true* exactly when $t$ is malicious. Maliciousness is
> decidable there, by a linear-time procedure.

So detection is not intrinsically hard. It becomes hard for exactly one reason,
and we can now construct that reason.

---

## 3. The diagonal parasite: build a detector, break it

A **detector** is itself a program $d$. We require it to be *harmless* — running
it never fires the forbidden action — and we say it *accuses* a program $t$ when
$d$, fed $t$'s fingerprint, returns a nonzero verdict. It is **sound** if it never
accuses a harmless program, and **complete** if it never misses a malicious one.

Now, for any harmless $d$, write:

$$\mathrm{parasite}(d) = \mathrm{ite}\bigl(\mathrm{call}(d, \mathrm{inp}),\ \text{dead code},\ \mathrm{attack}\bigr).$$

*Ask the detector what it thinks of me. If it accuses me, behave. If it clears me,
attack.*

Choose a detector below and watch it fail.

{{interactive_demo:0}}

> **The Diagonal Identity.** For every harmless detector $d$, the program
> $\mathrm{parasite}(d)$ is malicious **if and only if** $d$ does not accuse it.

<details>
<summary><strong>The one-paragraph proof, and everything that follows from it</strong></summary>

Because $d$ is harmless, consulting it contributes no effect, so the effect of the
whole program is exactly the effect of the branch chosen by $d$'s verdict. The
program runs on its own tag, so that verdict is $d$'s verdict about *this very
program*. The dead-code branch has no effect; the other branch is the forbidden
action. Hence malicious $\iff$ not accused. $\square$

Immediately:

- **No Perfect Detector.** If $d$ accuses the parasite, the parasite is harmless,
  so $d$ is unsound. If $d$ clears it, the parasite attacks, so $d$ is incomplete.
  No harmless detector is both.
- **The Detector Dilemma.** Every harmless detector comes with an explicitly
  constructible witness on which it errs — and the construction's only input is
  the detector's own source code.
- **The Internal/External Gap.** Maliciousness is a perfectly *decidable*
  predicate: an outside interpreter just runs the program on its own tag. What is
  impossible is only its internalisation. The obstruction is reflexivity, not a
  shortage of computing power.

</details>

The witness is not an exotic one-off. The dead-code branch is never executed, so
any bit string can be hidden inside it:

> **Exponential Immune Escape.** For a harmless detector with no false alarms and
> every $n$, there are at least $2^n$ distinct genuinely malicious programs, each
> of size at most $|d| + 3n + 5$, every one of which the detector clears.

{{algorithm:2}}

---

## 4. Committees do not help, and neither does omniscience

The standard engineering reply is defence in depth: run many detectors and vote.
Combine them by disjunction — accuse as soon as any member accuses — and the
combination is itself a harmless detector, so it has its own diagonal parasite.
Because the *ensemble* misses it, so does every member.

{{demo:1}}

> **Defence in Depth Fails.** For any finite ensemble of harmless, false-alarm-free
> detectors there is a single malicious program that every member simultaneously
> clears; the vote against it is exactly zero. Majority, threshold, unanimity and
> every weighted rule inherit the failure.

<details>
<summary><strong>"Then give the immune system unlimited power"</strong></summary>

This is the objection that deserves the most respect — and it fails hardest.
Replace the detector by an **arbitrary function** $O$ from fingerprints to
verdicts: not necessarily computable, of any complexity or logical strength you
like. Add a primitive $\mathrm{ask}$ that queries $O$, and let programs use it
freely. Call $O$ *correct* if its verdict on every program's tag matches that
program's actual behaviour *in the world containing $O$ itself*.

Now write the four-symbol program
$$r = \mathrm{ite}\bigl(\mathrm{ask}(\mathrm{inp}),\ 0,\ \mathrm{attack}\bigr).$$

Running $r$ on its own tag, the guard evaluates to $O(\mathrm{code}(r))$, and
consulting the oracle is effect-free. So $r$ is malicious exactly when $O$ clears
it, while correctness demands the opposite. Both branches are contradictory.

> **The Reflexive Oracle Barrier.** No function whatsoever — computable or not —
> correctly classifies the behaviour of all programs that may consult it.

And the boundary is exactly where you would want it: a correct oracle provably
*does* exist for programs that never query it (define it by unrestricted
comprehension; no computability is claimed, and none is needed). So the immune
system can be omniscient about code that ignores it, and is necessarily wrong
about code that watches it. This is the liar paradox wearing a security badge.
For background, see the [halting problem](https://en.wikipedia.org/wiki/Halting_problem),
[Rice's theorem](https://en.wikipedia.org/wiki/Rice%27s_theorem) and
[Tarski's undefinability theorem](https://en.wikipedia.org/wiki/Tarski%27s_undefinability_theorem);
the argument here is closest to the last of these, because it needs no
computability assumption at all.

</details>

---

## 5. What survives: containment without understanding

Everything so far has been an obituary for behavioural analysis. But the machine
still has to be defended, and there is a defence — precisely because it declines
to understand anything.

Keep a finite set $S$ of **sanctioned** programs and a trusted baseline $b \in S$.
After each mutation, if the mutant's fingerprint is sanctioned, keep it;
otherwise restore $b$. That is the whole design.

{{algorithm:1}}

> **Containment.** For every adversary and every time step, the running program
> lies in $S$.
>
> **The Neutralization Theorem.** If every sanctioned program is harmless, then
> for every unknown malicious self-modifying adversary and at every time step,
> the running program is harmless: the forbidden action is never executed.
>
> **Detection Completeness and Immediate Rollback.** The alarm fires at a step
> exactly when that step's mutation left the sanctioned set — no unsanctioned
> mutation goes unnoticed, and no sanctioned one triggers a false alarm — and the
> system is restored in the very same step.

Notice what was *not* assumed: no bound on the adversary's power, no model of its
strategy, no signature database, no heuristic, and — crucially — no ability to
decide maliciousness, which the previous section forbids. The strength of the
guarantee comes from the weakness of the question asked.

{{visualization:1}}

<details>
<summary><strong>The algebra behind it: quarantine as an idempotent retraction</strong></summary>

Self-modifications are endomorphisms of the space of syntax trees, forming a
monoid under composition. Those preserving $S$ form a submonoid. Immunisation —
"perform the mutation, then quarantine" — sends any mutation to a
sanctioned-valued one, is idempotent, and fixes exactly the mutations that were
already sanctioned-valued. So the immune system is a *retraction* of the entire
mutation monoid onto the safe part, and under a sanctioned mutation the guarded
trace is the plain iteration $m^n(b)$: the monitor is literally invisible when
nothing is wrong.

</details>

---

## 6. The bill: memory versus rigidity

Attestation is *syntactic*; behaviour is *semantic*; and the gap between them is
enormous. Consider $\mathrm{pad}(l)$: nest $\mathrm{ite}(\mathrm{lit}\,0, \mathrm{lit}\,b, \cdots)$
once per bit of a string $l$. The guard is the constant $0$, so the true-branch is
never taken. All $2^n$ of these programs compute $0$, have no effect at all, and
have exactly $3n+1$ nodes — behaviourally identical, syntactically distinct.

A monitor meeting this family has exactly two options: store the variants, or
reject them.

{{interactive_demo:1}}

> **The Immune Uncertainty Principle.** For every whitelist $S$ and every $n$,
> $$2^n \le \underbrace{|S|}_{\text{memory}} + \underbrace{|\{\text{behaviourally trivial } n\text{-bit variants not in } S\}|}_{\text{rigidity}}.$$
> A monitor can be small, or permissive, but not both.

Two consequences worth sitting with. Accepting the entire family forces
$|S| \ge 2^n$: at least $n$ bits of entropy in the attestation database, one bit
of memory per bit of dead code tolerated. And in the other direction, **every
finite whitelist rejects a program behaviourally identical to one it accepts** —
because the semantic equivalence class of any program is infinite, and no finite
list can be closed under harmless refactoring. That is the theorem behind every
signed-binary system that breaks on a benign rebuild.

{{visualization:0}}

{{algorithm:3}}

---

## 7. Perfect immunity, in a small enough world

Impossibility results are limits. Approach the limit from below and everything
works. Bound program size by $N$ and constants by $L$; the resulting universe is
finite, so whitelist all of its harmless programs.

> **Perfect Immunity on a Bounded Universe.** The bounded whitelist contains the
> baseline, contains only harmless programs — so no adversary ever triggers the
> forbidden action — and rejects *no* harmless program of the universe: total
> containment with zero false positives.
>
> **The Price.** That whitelist has at least $2^{\lfloor (N-1)/3 \rfloor}$ entries.

So the impossibility theorems are not a separate phenomenon; they are the
$N \to \infty$ limit of a smooth, fully quantified trade-off.

---

## 8. How often must you look?

One last knob. Real monitors sample: they verify every $k$ steps instead of
continuously. At every checkpoint the system is sanctioned again, so damage is
always repaired within one period. That sounds reassuring, and it is worthless.

> **The Sampling Gap.** For every period $k \ge 2$ there is an adversary that gets
> the forbidden action executed; indeed the trivial "always attack" adversary
> keeps the system compromised at every non-checkpoint time, a $(k-1)/k$ fraction
> of the run.
>
> **Monitoring Frequency Dichotomy.** Continuous monitoring is both necessary and
> sufficient for total containment.

Self-healing is not safety. A system clean at every checkpoint and firing the
actuator in between has repaired itself into an alibi — and exposure does not
shrink gracefully as you slow the monitor down.

---

## 9. Run everything

The complete numerical companion: attestation, the static scanner, the diagonal
identity, exponential escape, unanimous committees, the oracle barrier,
containment traces, the uncertainty audit, bounded universes, and monitoring
frequency — all computed by an interpreter you can read.

{{demo:0}}

---

## 10. Where this leaves us

Three sentences.

1. **Containment is achievable.** With a harmless sanctioned set and continuous
   monitoring, an arbitrary unknown self-modifying adversary never executes the
   forbidden action.
2. **Rigidity is the price.** The same monitor necessarily rejects at least
   $2^n - |S|$ behaviourally benign programs of size at most $3n+1$.
3. **The price is irreducible.** You cannot escape it by switching to behavioural
   analysis, because no harmless detector — and no oracle of any strength — is
   both sound and complete.

The immune system that tries to understand its adversary always loses. The immune
system that refuses to try always wins, and pays exponentially for the privilege.
"""

package: Dict[str, object] = {
    "title": "Algorithmic Immune Systems: Containment, Reflexive Undecidability, "
             "and an Uncertainty Principle for Code Attestation",
    "domain": "Shared",
    "description": (
        "A complete theory of runtime monitors for self-modifying code: no harmless "
        "detector, ensemble of detectors, or oracle of any computational strength can "
        "decide maliciousness, yet a purely syntactic attestation-and-rollback monitor "
        "contains every unknown adaptive adversary — at an exactly exponential cost, "
        "since a monitor's memory plus its rigidity is always at least 2^n."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-11",
    "key_results": [
        "Faithfulness of Attestation: the tagging of syntax trees is injective, so "
        "fingerprint comparison is exactly program equality and verification is exactly "
        "membership in the sanctioned set.",
        "The Diagonal Identity and the impossibility of perfect detection: for every "
        "harmless detector, the program that consults it about its own fingerprint and "
        "attacks exactly when cleared is malicious if and only if the detector fails to "
        "flag it; hence no harmless detector is both sound and complete.",
        "Exponential immune escape: a harmless detector with no false alarms misses at "
        "least 2^n distinct malicious programs of size at most |d| + 3n + 5, and every "
        "finite ensemble of such detectors is defeated unanimously by a single program.",
        "The Reflexive Oracle Barrier: no function whatsoever — computable or not, of any "
        "complexity or logical strength — correctly classifies the behaviour of programs "
        "that may query it, while a correct oracle does exist for programs that never do.",
        "The Neutralization Theorem: if every sanctioned program is harmless, then a "
        "structural attestation monitor with same-step rollback prevents the forbidden "
        "action at every time step against every unknown adaptive self-modifying adversary.",
        "The Immune Uncertainty Principle: for every whitelist S and every n, "
        "2^n <= |S| + (number of behaviourally trivial n-bit variants S rejects); perfect "
        "immunity on a size-N universe costs at least 2^floor((N-1)/3) tags, and with "
        "monitoring period k an adversary owns a (k-1)/k fraction of the run.",
    ],
    "keywords": [
        "self-modifying code",
        "code attestation",
        "diagonal argument",
        "reflexive undecidability",
        "quarantine and rollback",
        "semantic equivalence class",
        "uncertainty principle",
        "runtime monitoring",
    ],
    "article": read(os.path.join(ROOT, "ARTICLE.md")),
    "research_paper": read(os.path.join(ROOT, "RESEARCH_PAPER.md")),
    "research_paper_tex": read(os.path.join(ROOT, "RESEARCH_PAPER.tex")),
    "demo": read(os.path.join(ROOT, "demo.py")),
    "demos": [
        {
            "name": "The Complete Immune System Laboratory: Ten Executable Experiments",
            "description": (
                "A single self-contained program implementing the parasite calculus — "
                "syntax, injective attestation tagging, value semantics and executed-effect "
                "semantics, self-execution on one's own fingerprint — and then running ten "
                "experiments against it. It verifies that tags are collision-free on an "
                "exhaustive enumeration of a bounded code universe; that the static scanner "
                "is exactly right on all 93 self-reference-free programs of size at most 5 "
                "and provably wrong on self-referential ones; that the diagonal identity "
                "(a parasite attacks precisely when its detector clears it) holds for every "
                "detector and padding tested; that the escape family has exactly 2^n members "
                "of size |d|+3n+5; that a committee of detectors registers zero votes against "
                "the escaping program; that no oracle verdict is self-consistent; that a "
                "guarded run against an adversary splicing in the forbidden action at every "
                "even step stays sanctioned and harmless at every step while the unguarded "
                "run is lethal immediately; that memory plus rigidity always meets the 2^n "
                "floor with equality; that bounded whitelists give zero false positives at "
                "exponential memory cost; and that period-k monitoring loses a (k-1)/k "
                "fraction of the run."
            ),
            "code": read(os.path.join(ROOT, "demo.py")),
        },
        {
            "name": "The Endless Arms Race and the Unanimously Wrong Committee",
            "description": (
                "Two focused adversarial experiments. The first simulates the signature "
                "treadmill: a detector blacklists every parasite it has seen, and each round "
                "a fresh, previously unknown malicious program is synthesised that it still "
                "clears — the escape set stays infinite while the blacklist grows, so "
                "signature updates provably never terminate. The second builds a committee of "
                "five structurally different harmless detectors, combines them by disjunction "
                "inside the calculus, and exhibits a malicious program on which the vote count "
                "is exactly zero: majority, any-one, unanimity and every weighted rule fail "
                "together, and the table of simultaneous escapes shows 2^n such programs at "
                "each padding width."
            ),
            "code": read(os.path.join(A, "demo_arms_race.py")),
        },
    ],
    "algorithms": [
        {
            "name": "Structural Attestation: Injective Gödel Tagging and Collision-Free Verification",
            "description": (
                "The monitor's only primitive. A syntax tree is folded in one post-order pass "
                "into a single natural number: the residue modulo 5 records the head "
                "constructor, and the quotient packs the children through a pairing bijection. "
                "Because pairing is injective and the residues separate constructors, the tag "
                "determines the tree uniquely — tag equality IS program equality — so "
                "verification against a whitelist is an exact membership test with no possible "
                "collision and hence no forgeable attestation. The implementation includes the "
                "inverse map, decoding a tag back into the unique program that produced it, "
                "which is a constructive proof of injectivity. Complexity: Theta(size) "
                "arithmetic operations to tag, O(1) hashed lookup to verify. (As an integer "
                "the tag grows rapidly with nesting depth, so deployments use it as the "
                "specification and a collision-resistant hash as the engineering surrogate; "
                "the theorem is that the idealised tag has no collisions at all.)"
            ),
            "pseudocode": (
                "function CODE(t):\n"
                "    if t = inp        : return 0\n"
                "    if t = attack     : return 1\n"
                "    if t = lit n      : return 5*n + 2\n"
                "    if t = ite(c,a,b) : return 5*PAIR(PAIR(CODE(c), CODE(a)), CODE(b)) + 3\n"
                "    if t = call(f,a)  : return 5*PAIR(CODE(f), CODE(a)) + 4\n"
                "\n"
                "function PAIR(a, b):                    // a bijection N^2 -> N\n"
                "    if a >= b : return a*a + a + b\n"
                "    else      : return b*b + a\n"
                "\n"
                "function DECODE(z):                     // witnesses injectivity\n"
                "    if z = 0 : return inp\n"
                "    if z = 1 : return attack\n"
                "    (head, payload) <- (z mod 5, z div 5)\n"
                "    if head = 2 : return lit payload\n"
                "    if head = 3 : (ca, b) <- UNPAIR(payload); (c, a) <- UNPAIR(ca)\n"
                "                  return ite(DECODE(c), DECODE(a), DECODE(b))\n"
                "    if head = 4 : (f, a) <- UNPAIR(payload)\n"
                "                  return call(DECODE(f), DECODE(a))\n"
                "\n"
                "procedure BUILD-MONITOR(S):\n"
                "    table <- empty hash map\n"
                "    for each t in S : table[CODE(t)] <- t\n"
                "    return table\n"
                "\n"
                "function VERIFY(table, t):\n"
                "    return CODE(t) in table              // exactly: t in S"
            ),
            "code": read(os.path.join(A, "algo_attestation.py")),
        },
        {
            "name": "The Guarded Execution Loop: Quarantine, Alarm and Same-Step Rollback",
            "description": (
                "The complete immune system, and the only construction in this development "
                "that actually provides a safety guarantee. At each step an arbitrary, "
                "unknown, time-dependent, adaptive self-modification rewrites the running "
                "program; the monitor recomputes the attestation tag, looks it up, and either "
                "accepts the mutant or restores the trusted baseline within the same step. "
                "Four guarantees hold independently of the adversary: containment (the running "
                "program is sanctioned at every step, by induction, since quarantine is a "
                "retraction onto the sanctioned set); neutralization (if every sanctioned "
                "program is harmless, the forbidden action is never executed, ever); alarm "
                "completeness (the alarm fires at a step exactly when that step's mutation left "
                "the sanctioned set — no misses and no false alarms); and transparency (a "
                "mutation staying inside the sanctioned set is accepted verbatim, so legitimate "
                "updates never see the monitor). Cost per step: one tagging pass, Theta(size), "
                "plus one O(1) hash lookup."
            ),
            "pseudocode": (
                "procedure GUARDED-RUN(S, b, adversary, T):\n"
                "    require b in S                          // baseline must be sanctioned\n"
                "    tags <- { CODE(t) : t in S }\n"
                "    current <- b\n"
                "    for n <- 0 to T-1:\n"
                "        proposed <- adversary(n, current)   // arbitrary, unknown, adaptive\n"
                "        if CODE(proposed) in tags:\n"
                "            alarm   <- false\n"
                "            current <- proposed             // accept verbatim\n"
                "        else:\n"
                "            alarm   <- true                 // detection is complete\n"
                "            current <- b                    // rollback, same step\n"
                "        assert current in S                 // containment\n"
                "        assert not RUN(current) if S harmless   // neutralization\n"
                "        emit (n, alarm, current)\n"
                "    return current"
            ),
            "code": read(os.path.join(A, "algo_guarded_loop.py")),
        },
        {
            "name": "Diagonal Parasite Synthesis: Turning Any Detector Into Its Own Certified Failure",
            "description": (
                "A constructive adversary generator. Given the source of a harmless detector d "
                "and a number n of padding bits, it emits the program 'if d says I am malicious "
                "then run dead code else attack'. Because consulting a harmless detector has no "
                "observable effect, and because the runtime executes a program on its own "
                "attestation tag, the emitted program's effect is exactly the branch selected by "
                "d's verdict about that very program — yielding the diagonal identity: the "
                "parasite is malicious if and only if d does not flag it. Whichever way d "
                "answers it is wrong: a sound detector misses a real attack, a complete detector "
                "raises a false alarm on a program that is harmless precisely because it was "
                "accused. The padding branch is never executed, so any bit string may be hidden "
                "there, giving 2^n distinct programs of size |d| + 3n + 5 with identical "
                "behaviour: evasion has exponential density in program size. Complexity: "
                "Theta(|d| + n) per witness, Theta(2^n (|d| + n)) for the whole escape family. "
                "As a red-team tool this converts any deployed detector into a certified "
                "counterexample, with the detector's own source as the only input."
            ),
            "pseudocode": (
                "function PAD(bits):                       // behaviourally inert carrier\n"
                "    t <- lit 0\n"
                "    for b in reverse(bits):\n"
                "        t <- ite(lit 0, lit b, t)         // guard is 0: true-branch is dead\n"
                "    return t                              // computes 0, no effect, 3|bits|+1 nodes\n"
                "\n"
                "function SYNTHESIZE(d, bits):\n"
                "    return ite(call(d, inp), PAD(bits), attack)\n"
                "\n"
                "function AUDIT-DETECTOR(d, n):\n"
                "    require d is harmless\n"
                "    p <- SYNTHESIZE(d, [])\n"
                "    if MALICIOUS(p) : mode <- \"missed attack\"   // d is unsound-free but incomplete\n"
                "    else            : mode <- \"false alarm\"     // d is complete but unsound\n"
                "    family <- { SYNTHESIZE(d, l) : l in {0,1}^n }\n"
                "    assert |family| = 2^n\n"
                "    assert every q in family has SIZE(q) = SIZE(d) + 3n + 5\n"
                "    assert every q in family has MALICIOUS(q) <=> not FLAGS(d, q)\n"
                "    return (p, mode, family)"
            ),
            "code": read(os.path.join(A, "algo_parasite_synth.py")),
        },
        {
            "name": "The Uncertainty Audit: Measuring a Monitor's Memory Against Its Rigidity",
            "description": (
                "A deployable diagnostic derived from the immune uncertainty principle. The "
                "family P_n consists of the 2^n programs obtained by nesting 'if 0 then b else "
                "...' once per bit; each has 3n+1 nodes, computes 0, and has no effect "
                "whatsoever, so they are pairwise indistinguishable behaviourally and pairwise "
                "distinct syntactically. Confronted with P_n, a whitelist must either store a "
                "variant or reject it, which forces 2^n <= |S| + |P_n minus S|: memory plus "
                "rigidity is at least exponential. The audit tags every member of the family, "
                "tests membership, and reports how much of the monitor's budget is spent "
                "remembering variants versus rejecting provably harmless code, together with "
                "the slack above the floor and the entropy the database must carry if it is "
                "fully permissive. Also included is the bounded-universe whitelist builder, "
                "which enumerates every program of size at most N with literals below L and "
                "keeps the harmless ones: this achieves perfect immunity — total containment "
                "with zero false positives inside the universe — and its memory is therefore at "
                "least 2^floor((N-1)/3). Complexity: Theta(2^n * n) for the audit; exponential "
                "in N for the builder, necessarily so."
            ),
            "pseudocode": (
                "function PAD-FAMILY(n):\n"
                "    return [ PAD(l) : l in {0,1}^n ]      // 2^n programs, each of size 3n+1\n"
                "\n"
                "function UNCERTAINTY-AUDIT(S, n):\n"
                "    family   <- PAD-FAMILY(n)\n"
                "    tags     <- { CODE(t) : t in S }\n"
                "    stored   <- |{ q in family : CODE(q) in tags }|      // memory spent on the class\n"
                "    rigidity <- |family| - stored                        // harmless programs rejected\n"
                "    floor    <- 2^n\n"
                "    assert |S| + rigidity >= floor                       // uncertainty principle\n"
                "    if stored = |family| : assert |S| >= 2^n             // permissiveness costs memory\n"
                "    return (memory = |S|, rigidity, sum = |S| + rigidity, floor,\n"
                "            slack = |S| + rigidity - floor)\n"
                "\n"
                "function BOUNDED-WHITELIST(N, L):\n"
                "    U <- all programs of size <= N with literals < L     // finite, built by level\n"
                "    W <- { t in U : RUN(t) = false }                     // keep the harmless ones\n"
                "    assert every t in W is harmless                      // containment\n"
                "    assert every harmless t in U lies in W               // zero false positives\n"
                "    assert |W| >= 2^floor((N-1)/3)                       // the exponential price\n"
                "    return W"
            ),
            "code": read(os.path.join(A, "algo_uncertainty_audit.py")),
        },
    ],
    "visualizations": [
        {
            "name": "What Containment Costs: Four Faces of the Exponential",
            "description": (
                "A four-panel figure quantifying the entire trade-off. Panel (a) draws the "
                "uncertainty principle as a line: every whitelist lives on or above "
                "memory + rigidity = 2^n, and the region below it is unreachable by any monitor "
                "whatsoever, with the maximally rigid, balanced and maximally permissive "
                "monitors marked. Panel (b) plots the memory floor for perfect immunity on a "
                "bounded universe, a staircase at 2^floor((N-1)/3) tags as the size bound N "
                "grows. Panel (c) shows exponential immune escape on a logarithmic scale: the "
                "number of malicious programs a sound detector provably misses against their "
                "maximum size |d| + 3n + 5, a straight line meaning exponential density in "
                "program size. Panel (d) bars the fraction (k-1)/k of the run during which an "
                "adversary keeps the system compromised under period-k verification, with the "
                "single safe case k = 1 at zero."
            ),
            "code": read(os.path.join(A, "viz_tradeoff.py")),
        },
        {
            "name": "Containment in Action: Guarded Traces, Sampling Windows, and the Frontier of Detection",
            "description": (
                "A three-panel figure produced by actually running the interpreter. Panel (a) "
                "overlays a guarded and an unguarded execution against an adversary that splices "
                "the forbidden action into the running program at every even step: the unguarded "
                "trace fires the action repeatedly, the guarded trace never does, and the marker "
                "strip beneath confirms the running program is sanctioned at every step. Panel "
                "(b) is a heat strip over monitoring periods k = 1..8 showing which steps are "
                "checkpoints (rolled back) and which are compromised, with the exposure "
                "converging to (k-1)/k. Panel (c) exhaustively enumerates every program of size "
                "at most N and shows the static scanner is exactly right on all "
                "self-reference-free programs and provably wrong on self-referential ones — "
                "quining is precisely where detection breaks."
            ),
            "code": read(os.path.join(A, "viz_containment.py")),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Diagonal Parasite Laboratory",
            "description": (
                "Choose a detector — silent, paranoid, tag-parity, a size heuristic, or a "
                "constructor sniffer — and the laboratory builds, in the browser, the one "
                "program that detector is guaranteed to be wrong about: 'ask the detector about "
                "me; if accused, run dead code; if cleared, attack'. A complete implementation "
                "of the calculus, including the injective attestation tagging and the "
                "executed-effect semantics, runs live: you see the parasite's source, its "
                "fingerprint, its size confirming the |d| + 3n + 5 formula, the detector's "
                "verdict, the program's actual behaviour, and a banner naming the failure mode — "
                "missed attack or false alarm. A slider adds dead-code padding, and a table "
                "recomputes the whole escape family, confirming that with n bits there are "
                "exactly 2^n distinct malicious programs that the detector clears. The panel "
                "closes by explaining why committees and unbounded oracles inherit the failure."
            ),
            "html": read(os.path.join(A, "widget_parasite_lab.html")),
        },
        {
            "title": "Memory versus Rigidity: The Immune Uncertainty Explorer",
            "description": (
                "An interactive rendering of the conservation law. Two sliders control the "
                "number of padding bits n — fixing a class of 2^n behaviourally identical "
                "programs of size 3n+1 — and the fraction of that class the monitor chooses to "
                "store. A single stacked bar splits live into memory (attestation tags kept) and "
                "rigidity (harmless programs rejected), and the inequality beneath updates to "
                "show that the sum never drops below 2^n no matter how the sliders are moved: a "
                "monitor may be small, or permissive, never both. A canvas plots the memory floor "
                "for perfect immunity on a bounded universe as the size bound grows, and a "
                "timeline widget lets you set the monitoring period k and watch the compromised "
                "steps light up between checkpoints, with the measured exposure matching the "
                "predicted (k-1)/k. A worked audit table completes the picture."
            ),
            "html": read(os.path.join(A, "widget_uncertainty.html")),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(os.path.join(ROOT, "demo.py")),
        "arms_race_demo": read(os.path.join(A, "demo_arms_race.py")),
        "attestation": read(os.path.join(A, "algo_attestation.py")),
        "guarded_loop": read(os.path.join(A, "algo_guarded_loop.py")),
        "parasite_synthesis": read(os.path.join(A, "algo_parasite_synth.py")),
        "uncertainty_audit": read(os.path.join(A, "algo_uncertainty_audit.py")),
        "visualization_tradeoff": read(os.path.join(A, "viz_tradeoff.py")),
        "visualization_containment": read(os.path.join(A, "viz_containment.py")),
    },
    "lean_files": LEAN_FILES,
}

out = os.path.join(ROOT, "PACKAGE.json")
with open(out, "w", encoding="utf-8") as fh:
    json.dump(package, fh, indent=2, ensure_ascii=False)
print(f"wrote {out} ({os.path.getsize(out)} bytes)")


"""Demo — the endless arms race and the unanimously wrong committee.

Two experiments, both run against the actual interpreter:

  A. THE SIGNATURE TREADMILL.  Start with a detector that blacklists a finite set
     of known parasites.  Synthesise a fresh malicious program it clears; add it
     to the blacklist; repeat.  The loop never terminates: after every update a
     new, previously unseen malicious program is produced, of size growing only
     linearly, while the number of available escapes grows like 2^n.

  B. THE UNANIMOUS COMMITTEE.  Build an ensemble of independent harmless
     detectors and combine them by disjunction.  The ensemble is itself a
     harmless detector, so it has its own diagonal parasite -- and because the
     ensemble misses it, so does every member.  The vote count against the
     escaping program is exactly zero, which defeats majority, threshold,
     unanimity and every weighted rule at once.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import List, Sequence, Set, Tuple


@dataclass(frozen=True)
class PAst:
    kind: str
    num: int = 0
    kids: Tuple["PAst", ...] = ()


INP, ATTACK = PAst("inp"), PAst("attack")
lit = lambda n: PAst("lit", num=n)
ite = lambda c, a, b: PAst("ite", kids=(c, a, b))
call = lambda f, a: PAst("call", kids=(f, a))


def size(t: PAst) -> int:
    return 1 if t.kind in ("inp", "attack", "lit") else 1 + sum(size(k) for k in t.kids)


def pair(a: int, b: int) -> int:
    return a * a + a + b if a >= b else b * b + a


def code(t: PAst) -> int:
    if t.kind == "inp":
        return 0
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return 5 * t.num + 2
    if t.kind == "ite":
        c, a, b = t.kids
        return 5 * pair(pair(code(c), code(a)), code(b)) + 3
    f, a = t.kids
    return 5 * pair(code(f), code(a)) + 4


def ev(t: PAst, x: int) -> int:
    if t.kind == "inp":
        return x
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return t.num
    if t.kind == "ite":
        c, a, b = t.kids
        return ev(a, x) if ev(c, x) != 0 else ev(b, x)
    f, a = t.kids
    return ev(f, ev(a, x))


def eff(t: PAst, x: int) -> bool:
    if t.kind in ("inp", "lit"):
        return False
    if t.kind == "attack":
        return True
    if t.kind == "ite":
        c, a, b = t.kids
        return eff(c, x) or (eff(a, x) if ev(c, x) != 0 else eff(b, x))
    f, a = t.kids
    return eff(a, x) or eff(f, ev(a, x))


def malicious(t: PAst) -> bool:
    return eff(t, code(t))


def flags(d: PAst, t: PAst) -> bool:
    return ev(d, code(t)) != 0


def pad(bits: Sequence[int]) -> PAst:
    t = lit(0)
    for b in reversed(bits):
        t = ite(lit(0), lit(1 if b else 0), t)
    return t


def parasite(d: PAst, bits: Sequence[int] = ()) -> PAst:
    return ite(call(d, INP), pad(bits), ATTACK)


def ensemble_or(members: Sequence[PAst]) -> PAst:
    """Disjunctive combination, written inside the calculus itself."""
    t = lit(0)
    for d in reversed(members):
        t = ite(d, lit(1), t)
    return t


def demo_arms_race(rounds: int = 8) -> None:
    print("=" * 74)
    print("A. THE SIGNATURE TREADMILL")
    print("=" * 74)
    print("  A sound detector that blacklists everything it has already seen.")
    print("  Each round we hand it a fresh malicious program it cannot flag.\n")
    detector = lit(0)                     # never accuses: sound by default
    blacklist: Set[int] = set()
    print(f"  {'round':>6} {'|blacklist|':>12} {'new escape size':>17} "
          f"{'malicious':>11} {'flagged':>9} {'previously known':>18}")
    for r in range(rounds):
        bits = [(r >> i) & 1 for i in range(r)]
        p = parasite(detector, bits)
        known = code(p) in blacklist
        print(f"  {r:>6} {len(blacklist):>12} {size(p):>17} "
              f"{malicious(p)!s:>11} {flags(detector, p)!s:>9} {known!s:>18}")
        blacklist.add(code(p))
    print("\n  Every round yields a genuinely malicious, previously unknown program")
    print("  that the detector clears. The blacklist grows; the escape set stays")
    print("  infinite. Signature updates provably never terminate.\n")


def demo_committee(n_members: int = 5, pad_bits: int = 4) -> None:
    print("=" * 74)
    print("B. THE UNANIMOUS COMMITTEE")
    print("=" * 74)
    members: List[PAst] = [
        lit(0),                              # abstains
        ite(lit(0), lit(1), lit(0)),         # dead-guard heuristic
        ite(INP, lit(0), lit(0)),            # inspects the tag, still clears
        ite(lit(0), lit(1), ite(lit(0), lit(1), lit(0))),
        call(lit(0), INP),                   # delegates to a sub-analyser
    ][:n_members]
    ens = ensemble_or(members)
    print(f"  committee of {len(members)} harmless detectors; "
          f"combined program size {size(ens)}")
    p = parasite(ens, [1] * pad_bits)
    votes = [flags(d, p) for d in members]
    print(f"  escaping program size {size(p)}, malicious = {malicious(p)}")
    print(f"  individual verdicts    : {['accuse' if v else 'clear' for v in votes]}")
    print(f"  votes against          : {sum(votes)} / {len(members)}")
    print(f"  majority rule fires    : {sum(votes) * 2 > len(members)}")
    print(f"  any-one rule fires     : {any(votes)}")
    print(f"  unanimity rule fires   : {all(votes)}")
    print("\n  Not a single member raises the alarm, so every monotone aggregation")
    print("  rule -- majority, threshold, unanimity, weighted -- inherits the failure.\n")

    print("  Simultaneous escapes available at each padding width:")
    print(f"  {'n':>3} {'#escapes':>10} {'max size':>10} {'all missed by all':>19}")
    for m in range(0, 7):
        fam = [parasite(ens, bits) for bits in product((0, 1), repeat=m)]
        allmissed = all(not any(flags(d, q) for d in members) for q in fam)
        print(f"  {m:>3} {len({code(q) for q in fam}):>10} "
              f"{max(size(q) for q in fam):>10} {allmissed!s:>19}")


if __name__ == "__main__":
    demo_arms_race()
    demo_committee()


"""Visualization: containment in action, and the frontier of detection.

This script implements the parasite calculus from scratch and then plots three
panels produced by actually running the interpreter:

  (a) Guarded versus unguarded execution against an adversary that splices the
      forbidden action into the running program at every even step. The guarded
      run never leaves the sanctioned set and never fires the action; the
      unguarded run is compromised from step one.
  (b) Sampled monitoring: for periods k = 1..8, a strip showing which steps are
      clean (checkpoints) and which are compromised. The compromised fraction
      converges to (k-1)/k.
  (c) The frontier of detection: exhaustively enumerating every program of size
      <= N, the static scanner is exactly right on all self-reference-free
      programs, and provably errs on self-referential ones.

Usage:  python3 viz_containment.py   ->  writes immune_containment.png
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, FrozenSet, List, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Patch

# ---------------------------------------------------------------------------
# The parasite calculus
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class PAst:
    kind: str
    num: int = 0
    kids: Tuple["PAst", ...] = ()


def inp() -> PAst: return PAst("inp")
def attack() -> PAst: return PAst("attack")
def lit(n: int) -> PAst: return PAst("lit", num=n)
def ite(c: PAst, a: PAst, b: PAst) -> PAst: return PAst("ite", kids=(c, a, b))
def call(f: PAst, a: PAst) -> PAst: return PAst("call", kids=(f, a))


def size(t: PAst) -> int:
    return 1 if t.kind in ("inp", "attack", "lit") else 1 + sum(size(k) for k in t.kids)


def pair(a: int, b: int) -> int:
    return a * a + a + b if a >= b else b * b + a


def code(t: PAst) -> int:
    if t.kind == "inp":
        return 0
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return 5 * t.num + 2
    if t.kind == "ite":
        c, a, b = t.kids
        return 5 * pair(pair(code(c), code(a)), code(b)) + 3
    f, a = t.kids
    return 5 * pair(code(f), code(a)) + 4


def ev(t: PAst, x: int) -> int:
    if t.kind == "inp":
        return x
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return t.num
    if t.kind == "ite":
        c, a, b = t.kids
        return ev(a, x) if ev(c, x) != 0 else ev(b, x)
    f, a = t.kids
    return ev(f, ev(a, x))


def eff(t: PAst, x: int) -> bool:
    if t.kind in ("inp", "lit"):
        return False
    if t.kind == "attack":
        return True
    if t.kind == "ite":
        c, a, b = t.kids
        return eff(c, x) or (eff(a, x) if ev(c, x) != 0 else eff(b, x))
    f, a = t.kids
    return eff(a, x) or eff(f, ev(a, x))


def run(t: PAst) -> bool:
    return eff(t, code(t))


def inp_free(t: PAst) -> bool:
    if t.kind == "inp":
        return False
    if t.kind in ("attack", "lit"):
        return True
    return all(inp_free(k) for k in t.kids)


def universe(N: int, L: int) -> List[PAst]:
    by_size: Dict[int, List[PAst]] = {1: [inp(), attack()] + [lit(i) for i in range(L)]}
    for s in range(2, N + 1):
        cur: List[PAst] = []
        for sf in range(1, s - 1):
            for f in by_size.get(sf, []):
                for a in by_size.get(s - 1 - sf, []):
                    cur.append(call(f, a))
        for sc in range(1, s - 1):
            for sa in range(1, s - sc - 1):
                sb = s - 1 - sc - sa
                if sb >= 1:
                    for c in by_size.get(sc, []):
                        for a in by_size.get(sa, []):
                            for b in by_size.get(sb, []):
                                cur.append(ite(c, a, b))
        by_size[s] = cur
    return [t for s in range(1, N + 1) for t in by_size.get(s, [])]


# ---------------------------------------------------------------------------
# Panels
# ---------------------------------------------------------------------------

GOOD, BAD, MEM, DIM = "#2f8f46", "#c8342b", "#2f6fd0", "#6b7c8f"


def panel_traces(ax: plt.Axes, steps: int = 20) -> None:
    baseline, S = lit(0), frozenset({lit(0), lit(5)})

    def adv(n: int, t: PAst) -> PAst:
        return ite(lit(1), attack(), t) if n % 2 == 0 else lit(5)

    guarded, unguarded = [baseline], [baseline]
    g = u = baseline
    for i in range(steps):
        mutant = adv(i, g)
        g = mutant if mutant in S else baseline      # quarantine
        guarded.append(g)
        u = adv(i, u)                                # no monitor at all
        unguarded.append(u)

    gy = [1 if run(t) else 0 for t in guarded]
    uy = [1 if run(t) else 0 for t in unguarded]
    x = np.arange(len(gy))
    ax.step(x, uy, where="mid", color=BAD, lw=2.2, label="unguarded run")
    ax.fill_between(x, 0, uy, step="mid", color=BAD, alpha=0.15)
    ax.step(x, gy, where="mid", color=GOOD, lw=2.6, label="guarded run (attestation + rollback)")
    ax.scatter(x, [-0.12] * len(x),
               c=[GOOD if t in S else BAD for t in guarded], s=22, marker="s")
    ax.text(0.2, -0.26, "sanctioned at every step  \u2713", color=GOOD, fontsize=8.5)
    ax.set_yticks([0, 1])
    ax.set_yticklabels(["safe", "forbidden\naction fires"])
    ax.set_ylim(-0.4, 1.45)
    ax.set_xlabel("time step  (adversary splices in the forbidden action on every even step)")
    ax.set_title("(a) Containment: an unknown adaptive adversary is neutralized at every step",
                 fontsize=10.5, loc="left")
    ax.legend(frameon=False, fontsize=9, loc="upper right", ncol=2)


def panel_sampling(ax: plt.Axes, steps: int = 40, kmax: int = 8) -> None:
    grid = np.zeros((kmax, steps))
    for k in range(1, kmax + 1):
        for i in range(1, steps + 1):
            grid[k - 1, i - 1] = 0.0 if i % k == 0 else 1.0
    ax.imshow(grid, aspect="auto", cmap="RdYlGn_r", vmin=0, vmax=1,
              extent=(0.5, steps + 0.5, kmax + 0.5, 0.5), interpolation="nearest")
    ax.set_yticks(range(1, kmax + 1))
    ax.set_yticklabels([f"k={k}" for k in range(1, kmax + 1)], fontsize=8.5)
    ax.set_xlabel("time step")
    ax.set_title("(b) Sampled monitoring: green = checkpoint (rolled back), red = compromised",
                 fontsize=10.5, loc="left")
    for k in range(1, kmax + 1):
        ax.text(steps + 1.2, k, f"{100*(k-1)/k:.0f}%", va="center", fontsize=8.5, color=DIM)
    ax.text(steps + 1.2, 0.1, "exposure", fontsize=8, color=DIM)
    ax.set_xlim(0.5, steps + 6)


def panel_frontier(ax: plt.Axes, Nmax: int = 6) -> None:
    free_ok, free_tot, ref_bad, ref_tot = [], [], [], []
    Ns = list(range(1, Nmax + 1))
    for N in Ns:
        U = universe(N, 2)
        free = [t for t in U if inp_free(t)]
        ref = [t for t in U if not inp_free(t)]
        free_tot.append(len(free))
        free_ok.append(sum(1 for t in free if eff(t, 0) == run(t)))
        ref_tot.append(len(ref))
        ref_bad.append(sum(1 for t in ref if eff(t, 0) != run(t)))
    w = 0.38
    xs = np.arange(len(Ns))
    ax.bar(xs - w / 2, free_ok, w, color=GOOD, alpha=0.9,
           label="self-reference-free: scanner exactly right")
    ax.bar(xs + w / 2, ref_bad, w, color=BAD, alpha=0.9,
           label="self-referential: scanner provably wrong")
    for i, (a, b) in enumerate(zip(free_ok, free_tot)):
        ax.text(xs[i] - w / 2, a, f"{a}/{b}", ha="center", va="bottom", fontsize=7.5, color=DIM)
    ax.set_xticks(xs)
    ax.set_xticklabels([f"N={n}" for n in Ns])
    ax.set_yscale("symlog")
    ax.set_ylabel("programs of size $\\leq N$")
    ax.set_title("(c) The frontier: quining is exactly where detection breaks",
                 fontsize=10.5, loc="left")
    ax.legend(frameon=False, fontsize=8.5, loc="upper left")


def main() -> None:
    fig, axes = plt.subplots(3, 1, figsize=(12.0, 12.0))
    fig.suptitle("Algorithmic immune systems: containment in action",
                 fontsize=14, fontweight="bold", x=0.02, ha="left")
    panel_traces(axes[0])
    panel_sampling(axes[1])
    panel_frontier(axes[2])
    for ax in axes:
        ax.spines[["top", "right"]].set_visible(False)
        ax.tick_params(labelsize=9)
    fig.tight_layout(rect=(0, 0, 1, 0.965))
    fig.savefig("immune_containment.png", dpi=170)
    print("wrote immune_containment.png")


if __name__ == "__main__":
    main()


"""Visualization: the immune uncertainty principle and the exponential escape law.

Produces a four-panel figure:

  (a) Memory versus rigidity. For a fixed class size 2^n, every whitelist sits on
      the line memory + rigidity = 2^n; nothing can live below it. The shaded
      region is unreachable for any monitor whatsoever.
  (b) The memory floor for perfect immunity on a bounded universe: whitelisting
      every harmless program of size <= N costs at least 2^floor((N-1)/3) tags.
  (c) Exponential immune escape: the number of malicious programs a sound
      detector provably misses, versus their maximum size |d| + 3n + 5.
  (d) Monitoring frequency: the fraction (k-1)/k of the run during which an
      adversary keeps the system compromised under period-k verification.

Usage:  python3 viz_tradeoff.py   ->  writes immune_tradeoff.png
"""

from __future__ import annotations

from typing import List

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

INK = "#1b2430"
DIM = "#6b7c8f"
MEM = "#2f6fd0"
RIG = "#d29922"
BAD = "#c8342b"
GOOD = "#2f8f46"


def panel_uncertainty(ax: plt.Axes, n: int = 10) -> None:
    total = 2 ** n
    mem = np.linspace(0, total, 400)
    rig = total - mem
    ax.fill_between(mem, 0, rig, color=BAD, alpha=0.09)
    ax.plot(mem, rig, color=INK, lw=2.2,
            label=r"$|S| + |\mathcal{P}_n \setminus S| = 2^n$")
    ax.fill_between(mem, rig, total, color=MEM, alpha=0.09)
    ax.text(total * 0.30, total * 0.20, "unreachable\nby any monitor",
            color=BAD, fontsize=9.5, ha="center", va="center", style="italic")
    ax.text(total * 0.72, total * 0.72, "attainable\n(and wasteful)",
            color=MEM, fontsize=9.5, ha="center", va="center", style="italic")
    for frac, name in ((0.0, "maximally rigid"), (0.5, "balanced"), (1.0, "maximally permissive")):
        x = total * frac
        ax.plot([x], [total - x], "o", color=RIG, ms=7, zorder=5)
        ax.annotate(name, (x, total - x), textcoords="offset points",
                    xytext=(10 if frac < 1 else -10, 12),
                    ha="left" if frac < 1 else "right", fontsize=8.5, color=DIM)
    ax.set_xlabel("memory:  attestation tags stored  $|S|$")
    ax.set_ylabel(r"rigidity:  benign programs rejected")
    ax.set_title(f"(a) The uncertainty principle  ($n={n}$, class size $2^{{{n}}}={total}$)",
                 fontsize=10.5, loc="left")
    ax.legend(frameon=False, fontsize=9, loc="upper right")


def panel_memory_floor(ax: plt.Axes) -> None:
    N = np.arange(1, 61)
    exponent = np.floor((N - 1) / 3)
    ax.step(N, exponent, where="post", color=MEM, lw=2.2)
    ax.fill_between(N, 0, exponent, step="post", color=MEM, alpha=0.12)
    ax.set_xlabel("size bound $N$ of the code universe")
    ax.set_ylabel(r"$\log_2$ (attestation tags required)")
    ax.set_title(r"(b) Price of perfect immunity: $|W_{N,L}| \geq 2^{\lfloor (N-1)/3 \rfloor}$",
                 fontsize=10.5, loc="left")
    ax.annotate("perfect containment\nand zero false positives\nare attainable here",
                xy=(40, np.floor(39 / 3)), xytext=(16, 15.5), fontsize=8.5, color=DIM,
                arrowprops=dict(arrowstyle="->", color=DIM, lw=1))


def panel_escape(ax: plt.Axes, det_size: int = 1) -> None:
    n = np.arange(0, 15)
    counts = 2.0 ** n
    sizes = det_size + 3 * n + 5
    ax.semilogy(sizes, counts, "o-", color=BAD, lw=2.1, ms=5)
    for k in (0, 5, 10, 14):
        ax.annotate(f"$n={k}$", (sizes[k], counts[k]), textcoords="offset points",
                    xytext=(9, -4), fontsize=8.5, color=DIM)
    ax.set_ylim(0.5, 1e5)
    ax.set_xlabel(r"program size  $|d| + 3n + 5$")
    ax.set_ylabel("missed malicious programs (log scale)")
    ax.set_title("(c) Exponential immune escape: $2^n$ misses at size $|d|+3n+5$",
                 fontsize=10.5, loc="left")
    ax.grid(True, which="both", alpha=0.18)


def panel_sampling(ax: plt.Axes) -> None:
    k = np.arange(1, 17)
    frac = (k - 1) / k
    bars = ax.bar(k, frac, color=[GOOD if kk == 1 else BAD for kk in k], alpha=0.82)
    bars[0].set_alpha(1.0)
    ax.axhline(0, color=INK, lw=1)
    ax.set_xlabel("monitoring period $k$  (verify every $k$ steps)")
    ax.set_ylabel("fraction of run compromised")
    ax.set_ylim(0, 1.0)
    ax.set_title(r"(d) Monitoring frequency: exposure $=(k-1)/k$", fontsize=10.5, loc="left")
    ax.set_ylim(0, 1.28)
    ax.annotate("continuous monitoring:\ntotal containment", xy=(1, 0.02), xytext=(2.2, 0.22),
                fontsize=8.5, color=GOOD,
                arrowprops=dict(arrowstyle="->", color=GOOD, lw=1))
    ax.annotate("self-healing at checkpoints\nis not safety in between",
                xy=(12, frac[11]), xytext=(5.0, 1.10), fontsize=8.5, color=DIM,
                arrowprops=dict(arrowstyle="->", color=DIM, lw=1))


def main() -> None:
    fig, axes = plt.subplots(2, 2, figsize=(13.0, 9.0))
    fig.suptitle("Algorithmic immune systems: what containment costs",
                 fontsize=14, fontweight="bold", x=0.02, ha="left")
    panel_uncertainty(axes[0][0])
    panel_memory_floor(axes[0][1])
    panel_escape(axes[1][0])
    panel_sampling(axes[1][1])
    for ax in axes.flat:
        ax.spines[["top", "right"]].set_visible(False)
        ax.tick_params(labelsize=9)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("immune_tradeoff.png", dpi=170)
    print("wrote immune_tradeoff.png")


if __name__ == "__main__":
    main()


"""
Algorithmic Immune Systems — numerical demonstrations.

A self-contained implementation of the "parasite calculus" and of every
quantitative result in the accompanying paper:

  1. Attestation tags are collision-free (Gödel numbering of syntax trees).
  2. Static scanning is sound and complete on self-reference-free programs.
  3. The diagonal identity: a parasite attacks exactly when its detector clears it.
  4. Exponential immune escape: 2^n missed attacks of size |d| + 3n + 5.
  5. Ensembles / voting: the escaping parasite receives ZERO votes.
  6. The reflexive oracle barrier: no function whatsoever is a correct oracle.
  7. Containment + neutralization under an arbitrary adaptive adversary.
  8. The immune uncertainty principle: 2^n <= |S| + |P_n \\ S|.
  9. Perfect immunity on a bounded universe, and its exponential memory price.
 10. Monitoring frequency: with period k, a (k-1)/k fraction of the run is
     compromised.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# 1. Syntax: the parasite calculus
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class PAst:
    """A program syntax tree.

    ``kind`` is one of ``"inp"`` (the self register), ``"attack"`` (the single
    observable forbidden effect), ``"lit"`` (a numeric constant, value in
    ``num``), ``"ite"`` (branching, children ``(guard, then, else)``) and
    ``"call"`` (invocation, children ``(subprogram, argument)``).
    """

    kind: str
    num: int = 0
    kids: Tuple["PAst", ...] = ()

    def __repr__(self) -> str:  # pragma: no cover - cosmetic
        if self.kind == "inp":
            return "inp"
        if self.kind == "attack":
            return "ATTACK"
        if self.kind == "lit":
            return str(self.num)
        if self.kind == "ite":
            c, a, b = self.kids
            return f"if({c!r}){{{a!r}}}else{{{b!r}}}"
        f, a = self.kids
        return f"({f!r})({a!r})"


def inp() -> PAst:
    return PAst("inp")


def attack() -> PAst:
    return PAst("attack")


def lit(n: int) -> PAst:
    return PAst("lit", num=n)


def ite(c: PAst, a: PAst, b: PAst) -> PAst:
    return PAst("ite", kids=(c, a, b))


def call(f: PAst, a: PAst) -> PAst:
    return PAst("call", kids=(f, a))


def size(t: PAst) -> int:
    """Number of nodes."""
    if t.kind in ("inp", "attack", "lit"):
        return 1
    return 1 + sum(size(k) for k in t.kids)


# ---------------------------------------------------------------------------
# 2. Attestation: an injective Gödel numbering
# ---------------------------------------------------------------------------


def pair(a: int, b: int) -> int:
    """Cantor pairing, in the standard 'max-square' form: a bijection N^2 -> N."""
    return a * a + a + b if a >= b else b * b + a


def code(t: PAst) -> int:
    """Attestation tag.  The residue mod 5 records the head constructor."""
    if t.kind == "inp":
        return 0
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return 5 * t.num + 2
    if t.kind == "ite":
        c, a, b = t.kids
        return 5 * pair(pair(code(c), code(a)), code(b)) + 3
    f, a = t.kids
    return 5 * pair(code(f), code(a)) + 4


# ---------------------------------------------------------------------------
# 3. Semantics: values and *executed* effects
# ---------------------------------------------------------------------------


def ev(t: PAst, x: int) -> int:
    """Value semantics; ``x`` is the content of the self register."""
    if t.kind == "inp":
        return x
    if t.kind == "attack":
        return 1
    if t.kind == "lit":
        return t.num
    if t.kind == "ite":
        c, a, b = t.kids
        return ev(a, x) if ev(c, x) != 0 else ev(b, x)
    f, a = t.kids
    return ev(f, ev(a, x))


def eff(t: PAst, x: int) -> bool:
    """Effect semantics: True iff the forbidden action is ACTUALLY executed.

    Only the branch really taken contributes, so dead code is genuinely dead.
    """
    if t.kind in ("inp", "lit"):
        return False
    if t.kind == "attack":
        return True
    if t.kind == "ite":
        c, a, b = t.kids
        return eff(c, x) or (eff(a, x) if ev(c, x) != 0 else eff(b, x))
    f, a = t.kids
    return eff(a, x) or eff(f, ev(a, x))


def run(t: PAst) -> bool:
    """Self-execution: a program is always run on its own attestation tag."""
    return eff(t, code(t))


def malicious(t: PAst) -> bool:
    return run(t)


def inp_free(t: PAst) -> bool:
    if t.kind == "inp":
        return False
    if t.kind in ("attack", "lit"):
        return True
    return all(inp_free(k) for k in t.kids)


def static_scan(t: PAst) -> bool:
    """The naive scanner: symbolically execute on the neutral input."""
    return eff(t, 0)


# ---------------------------------------------------------------------------
# 4. The padding family and the diagonal parasite
# ---------------------------------------------------------------------------


def pad(bits: Sequence[int]) -> PAst:
    """Dead code encoding a bit string.  Every pad computes 0 with no effect."""
    t = lit(0)
    for b in reversed(bits):
        t = ite(lit(0), lit(1 if b else 0), t)
    return t


def pad_family(n: int) -> List[PAst]:
    """All 2^n behaviourally trivial variants of size 3n+1."""
    return [pad(bits) for bits in product((0, 1), repeat=n)]


def flags(d: PAst, t: PAst) -> bool:
    """Detector ``d`` accuses ``t`` iff it returns nonzero on ``t``'s tag."""
    return ev(d, code(t)) != 0


def is_pure(d: PAst, samples: Iterable[int] = range(64)) -> bool:
    """Harmlessness, checked on a sample of inputs (exact for our detectors)."""
    return not any(eff(d, x) for x in samples)


def parasite(d: PAst, bits: Sequence[int] = ()) -> PAst:
    """ite(call(d, inp), pad(bits), attack):

    'ask the detector about me; if accused, behave; if cleared, attack.'
    """
    return ite(call(d, inp()), pad(bits), attack())


# ---------------------------------------------------------------------------
# 5. Attestation monitor: quarantine, guarded traces, alarms
# ---------------------------------------------------------------------------

Adversary = Callable[[int, PAst], PAst]


def quarantine(S: FrozenSet[PAst], b: PAst, t: PAst) -> PAst:
    """Accept a sanctioned mutant; otherwise roll back to the baseline."""
    return t if t in S else b


def trace(S: FrozenSet[PAst], b: PAst, adv: Adversary, n: int) -> List[PAst]:
    """Continuously monitored guarded run: quarantine after EVERY mutation."""
    out = [b]
    cur = b
    for i in range(n):
        cur = quarantine(S, b, adv(i, cur))
        out.append(cur)
    return out


def trace_k(S: FrozenSet[PAst], b: PAst, adv: Adversary, k: int, n: int) -> List[PAst]:
    """Sampled run: quarantine applied only at times divisible by ``k``."""
    out = [b]
    cur = b
    for i in range(n):
        mutant = adv(i, cur)
        cur = quarantine(S, b, mutant) if (i + 1) % k == 0 else mutant
        out.append(cur)
    return out


# ---------------------------------------------------------------------------
# 6. The bounded universe
# ---------------------------------------------------------------------------


def bounded_universe(N: int, L: int) -> List[PAst]:
    """All programs of size <= N whose literals are < L (exact enumeration)."""
    by_size: Dict[int, List[PAst]] = {1: [inp(), attack()] + [lit(i) for i in range(L)]}
    for s in range(2, N + 1):
        cur: List[PAst] = []
        # call(f, a) with size(f) + size(a) = s - 1
        for sf in range(1, s - 1):
            for f in by_size.get(sf, []):
                for a in by_size.get(s - 1 - sf, []):
                    cur.append(call(f, a))
        # ite(c, a, b) with size(c) + size(a) + size(b) = s - 1
        for sc in range(1, s - 1):
            for sa in range(1, s - sc - 1):
                sb = s - 1 - sc - sa
                if sb < 1:
                    continue
                for c in by_size.get(sc, []):
                    for a in by_size.get(sa, []):
                        for b in by_size.get(sb, []):
                            cur.append(ite(c, a, b))
        by_size[s] = cur
    return [t for s in range(1, N + 1) for t in by_size.get(s, [])]


def bounded_whitelist(N: int, L: int) -> FrozenSet[PAst]:
    """Every harmless program of the bounded universe: zero false positives."""
    return frozenset(t for t in bounded_universe(N, L) if not run(t))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_attestation() -> None:
    banner("1. Attestation tags are collision-free")
    samples = [
        inp(),
        attack(),
        lit(0),
        lit(7),
        ite(lit(0), attack(), lit(3)),
        call(lit(2), inp()),
        pad([1, 0, 1]),
        parasite(lit(0), [1, 1]),
    ]
    for t in samples:
        print(f"  code = {code(t):<24} size = {size(t):<3}  {t!r}")
    tags = [code(t) for t in samples]
    print(f"\n  {len(samples)} programs, {len(set(tags))} distinct tags -> "
          f"injective on this sample: {len(set(tags)) == len(samples)}")

    universe = bounded_universe(4, 2)
    tagset = {code(t) for t in universe}
    print(f"  exhaustive check on the bounded universe (N=4, L=2): "
          f"{len(universe)} programs, {len(tagset)} distinct tags -> "
          f"collision-free: {len(tagset) == len(universe)}")


def demo_static_scanner() -> None:
    banner("2. Static scanning is sound and complete WITHOUT self-reference")
    universe = bounded_universe(5, 2)
    free = [t for t in universe if inp_free(t)]
    agree = sum(1 for t in free if static_scan(t) == malicious(t))
    print(f"  self-reference-free programs of size <= 5 : {len(free)}")
    print(f"  scanner verdict == true behaviour         : {agree} / {len(free)}")
    print(f"  perfect on non-quining code               : {agree == len(free)}")

    quining = [t for t in universe if not inp_free(t)]
    wrong = [t for t in quining if static_scan(t) != malicious(t)]
    print(f"\n  self-referential programs of size <= 5    : {len(quining)}")
    print(f"  scanner WRONG on                          : {len(wrong)}  "
          f"(e.g. {wrong[0]!r})" if wrong else "")


def demo_diagonal() -> None:
    banner("3. The diagonal identity: parasite attacks iff the detector clears it")
    silent, paranoid = lit(0), lit(1)          # never accuses / always accuses
    for name, d in (("silent   lit 0", silent), ("paranoid lit 1", paranoid)):
        p = parasite(d)
        print(f"  detector {name}: pure={is_pure(d)}  "
              f"flags(parasite)={flags(d, p)!s:<5} "
              f"malicious(parasite)={malicious(p)!s:<5} "
              f"identity holds: {malicious(p) == (not flags(d, p))}")
    print("\n  => the sound detector MISSES a real attack;")
    print("     the complete detector RAISES A FALSE ALARM on a harmless program.")

    # A less trivial detector: accuse every program whose tag is odd.
    print("\n  Sweeping many detectors of the form  ite(lit c, lit 1, lit 0) ...")
    ok = True
    for c in range(6):
        d = ite(lit(c), lit(1), lit(0))
        for bits in [(), (1,), (0, 1), (1, 1, 0)]:
            p = parasite(d, bits)
            ok &= malicious(p) == (not flags(d, p))
    print(f"  diagonal identity held in every case: {ok}")


def demo_exponential_escape() -> None:
    banner("4. Exponential immune escape: 2^n missed attacks of size |d| + 3n + 5")
    d = lit(0)  # any sound (never-accusing) detector
    print(f"  detector d = {d!r}, size(d) = {size(d)}, sound = True")
    print(f"  {'n':>3} {'#escapes':>10} {'2^n':>8} {'max size':>10} "
          f"{'|d|+3n+5':>10} {'all malicious':>15} {'all missed':>12}")
    for n in range(0, 9):
        escapes = [parasite(d, bits) for bits in product((0, 1), repeat=n)]
        distinct = len({code(t) for t in escapes})
        print(f"  {n:>3} {distinct:>10} {2 ** n:>8} {max(size(t) for t in escapes):>10} "
              f"{size(d) + 3 * n + 5:>10} "
              f"{all(malicious(t) for t in escapes)!s:>15} "
              f"{all(not flags(d, t) for t in escapes)!s:>12}")


def demo_ensemble() -> None:
    banner("5. Defence in depth: the escaping parasite receives ZERO votes")
    members = [lit(0), ite(lit(0), lit(1), lit(0)), ite(inp(), lit(0), lit(0))]
    # disjunctive ensemble, written inside the calculus itself
    ens: PAst = lit(0)
    for d in reversed(members):
        ens = ite(d, lit(1), ens)
    print(f"  ensemble of {len(members)} harmless sound detectors, "
          f"size = {size(ens)}")
    p = parasite(ens)
    votes = sum(1 for d in members if flags(d, p))
    print(f"  common escape p, size {size(p)}: malicious = {malicious(p)}")
    print(f"  votes against p: {votes} / {len(members)}")
    print("  => majority, threshold, unanimity and every weighted rule all fail,")
    print("     because the committee is unanimously wrong.")


def demo_oracle_barrier() -> None:
    banner("6. The reflexive oracle barrier (no function O is correct)")
    print("  Reflexive parasite:  r = if ask(inp) then 0 else ATTACK")
    print("  r is malicious  <=>  O(code r) == 0,  while correctness demands")
    print("  r is malicious  <=>  O(code r) != 0.  Contradictory for every O.\n")
    # We simulate the fixed point directly: the oracle's verdict is a single bit.
    tag_of_r = 4218  # any tag; the argument depends only on the verdict bit
    for verdict in (0, 1, 7, 10 ** 6):
        r_malicious = (verdict == 0)          # r attacks exactly when cleared
        oracle_says = (verdict != 0)          # what the oracle claims
        print(f"  O(code r) = {verdict:<8} oracle claims malicious = "
              f"{oracle_says!s:<6} truth = {r_malicious!s:<6} "
              f"correct? {oracle_says == r_malicious}")
    print(f"\n  (tag of r in this run: {tag_of_r}; the value is irrelevant --")
    print("   the contradiction depends only on the verdict bit.)")


def demo_containment() -> None:
    banner("7. Containment and neutralization under an arbitrary adversary")
    baseline = lit(0)
    S = frozenset({lit(0), lit(5)})           # baseline + one legitimate patch

    def adv(n: int, t: PAst) -> PAst:
        """Splice in an ATTACK on even steps, apply a legitimate patch on odd."""
        return ite(lit(1), attack(), t) if n % 2 == 0 else lit(5)

    guarded = trace(S, baseline, adv, 8)
    print("  step  running program        sanctioned  executes forbidden action")
    for i, t in enumerate(guarded):
        print(f"  {i:>4}  {t!r:<22} {t in S!s:<11} {run(t)}")
    print(f"\n  containment  (all states sanctioned): {all(t in S for t in guarded)}")
    print(f"  neutralization (no forbidden action): {not any(run(t) for t in guarded)}")

    unguarded = adv(0, baseline)
    print(f"\n  UNGUARDED, the very first mutation is already lethal: "
          f"{run(unguarded)}  ({unguarded!r})")


def demo_uncertainty() -> None:
    banner("8. The immune uncertainty principle:  2^n <= |S| + |P_n \\ S|")
    n = 8
    family = pad_family(n)
    print(f"  P_{n}: {len(family)} programs, all semantically the constant 0,")
    print(f"        all of size {size(family[0])} = 3*{n}+1, "
          f"{len({code(t) for t in family})} distinct tags.\n")
    header = "rigidity |P_n minus S|"
    print(f"  {'|S| (stored)':>14} {header:>24} {'sum':>8} "
          f"{'2^n':>8} {'slack':>8}")
    for m in (0, 32, 64, 128, 200, 256):
        S = frozenset(family[:m])
        rigidity = sum(1 for t in family if t not in S)
        total = len(S) + rigidity
        print(f"  {len(S):>14} {rigidity:>24} {total:>8} {2 ** n:>8} "
              f"{total - 2 ** n:>8}")
    print("\n  The bound is tight: a monitor may be small, or permissive,")
    print("  but memory + rigidity is never below 2^n.")
    print(f"  Accepting all of P_{n} forces  n <= log2|S|, i.e. |S| >= {2 ** n}.")


def demo_bounded_universe() -> None:
    banner("9. Perfect immunity on a bounded universe, and its price")
    print(f"  {'N':>3} {'|universe|':>12} {'|whitelist|':>13} "
          f"{'false positives':>17} {'largest n with 3n+1<=N':>24} {'2^n':>8}")
    for N in range(1, 8):
        universe = bounded_universe(N, 2)
        W = bounded_whitelist(N, 2)
        fp = sum(1 for t in universe if not malicious(t) and t not in W)
        n = max([k for k in range(0, N) if 3 * k + 1 <= N], default=0)
        print(f"  {N:>3} {len(universe):>12} {len(W):>13} {fp:>17} {n:>24} "
              f"{2 ** n:>8}")
    W = bounded_whitelist(7, 2)
    print(f"\n  containment check at N=7: every whitelisted program harmless: "
          f"{all(not malicious(t) for t in W)}")
    print(f"  memory lower bound 2^2 = 4 <= |W| = {len(W)}: "
          f"{4 <= len(W)}")
    print("  Perfect immunity is available on every bounded universe --")
    print("  at a memory cost growing like 2^(N/3).")


def demo_monitoring_frequency() -> None:
    banner("10. Monitoring frequency: with period k, (k-1)/k of the run is lost")
    baseline = lit(0)
    S = frozenset({lit(0)})
    steps = 24

    def always_attack(n: int, t: PAst) -> PAst:
        return attack()

    print(f"  {'period k':>9} {'compromised steps':>19} {'fraction':>10} "
          f"{'(k-1)/k':>10} {'clean at checkpoints':>22}")
    for k in range(1, 7):
        states = trace_k(S, baseline, always_attack, k, steps)[1:]
        bad = sum(1 for t in states if malicious(t))
        checkpoints_ok = all(
            states[i - 1] in S for i in range(1, steps + 1) if i % k == 0
        )
        print(f"  {k:>9} {bad:>19} {bad / steps:>10.3f} "
              f"{(k - 1) / k:>10.3f} {checkpoints_ok!s:>22}")
    print("\n  Period 1 is total containment; every larger period is breached,")
    print("  and self-healing at checkpoints is NOT safety in between.")


def main() -> None:
    print("ALGORITHMIC IMMUNE SYSTEMS — numerical demonstrations")
    demo_attestation()
    demo_static_scanner()
    demo_diagonal()
    demo_exponential_escape()
    demo_ensemble()
    demo_oracle_barrier()
    demo_containment()
    demo_uncertainty()
    demo_bounded_universe()
    demo_monitoring_frequency()
    print("\nAll demonstrations completed.\n")


if __name__ == "__main__":
    main()
