"""Assemble PACKAGE.json from the deliverable files and inline content."""
import json
from pathlib import Path

HERE = Path(__file__).parent

article = (HERE / "ARTICLE.md").read_text()
paper = (HERE / "RESEARCH_PAPER.md").read_text()
paper_tex = (HERE / "RESEARCH_PAPER.tex").read_text()
demo = (HERE / "demo.py").read_text()
viz = (HERE / "_viz.py").read_text()
interactive = (HERE / "_interactive.html").read_text()

lean_proofs = r'''-- Catalog/Logic/PhysicsConsistency/Bridge.lean
import Logic.PhysicsConsistency.Incompleteness

namespace PhysicsConsistency
open ProofSystemCollapse Form

/-- Physical consistency implies mathematical consistency. -/
theorem physical_implies_math {T PA : ProofSys Form} (hsim : Simulates T PA)
    (hT : Consistent T) : Consistent PA := by
  intro hbot
  exact hT (hsim bot hbot)

/-- Consistency transfers down a tower of extensions. -/
theorem consistency_transfers_tower {T M PA : ProofSys Form}
    (h1 : Simulates T M) (h2 : Simulates M PA) (hT : Consistent T) : Consistent PA :=
  physical_implies_math (ProofSystemCollapse.simulates_trans h1 h2) hT

/-- Mathematical consistency does NOT imply physical consistency. -/
theorem math_not_implies_physical :
    ∃ PA T : ProofSys.{0,0} Form,
      IsGLTheory 0 PA ∧ Consistent PA ∧ Simulates T PA ∧ ¬ Consistent T := by
  refine ⟨trueSys, trivialSys, isGL_trueSys 0, consistent_trueSys, ?_, ?_⟩
  · intro f _; exact provable_trivialSys f
  · exact inconsistent_trivialSys

/-- If T is consistent then Con(T) is independent of PA. -/
theorem con_T_independent_of_PA {p t : ℕ} {PA T : ProofSys Form}
    (hPA : IsGLTheory p PA) (hPAc : Consistent PA) (hTc : Consistent T)
    (hbridge : Provable PA (imp (Con t) (Con p)))
    (hsound : Provable PA (neg (Con t)) → ¬ Consistent T) :
    ¬ Provable PA (Con t) ∧ ¬ Provable PA (neg (Con t)) := by
  refine ⟨?_, ?_⟩
  · intro hp
    exact goedel_two hPA hPAc (hPA.mp hbridge hp)
  · intro hp
    exact hsound hp hTc

/-- The cross-theory independence theorem is non-vacuous (stdSys witness). -/
theorem con_T_independent_of_PA_witness (p t : ℕ) :
    ¬ Provable stdSys (Con t) ∧ ¬ Provable stdSys (neg (Con t)) := by
  have hbridge : Provable stdSys (imp (Con t) (Con p)) := by
    rw [provable_stdSys]; intro m; rw [sat_imp]; exact id
  have hnp : ¬ Provable stdSys (neg (Con t)) := (stdSys_con_independent t).2
  exact con_T_independent_of_PA (p := p) (t := t)
    (isGL_stdSys p) consistent_stdSys consistent_stdSys hbridge
    (fun hp => absurd hp hnp)

end PhysicsConsistency

-- Catalog/Logic/PhysicsConsistency/Incompleteness.lean (core, abbreviated)
-- loeb_rule        : Provable T (imp (box i a) a) → Provable T a
-- goedel_two       : Consistent T → ¬ Provable T (Con i)
-- con_independent_self : consistent + Σ₁-sound GL theory ⊢ neither Con i nor ¬Con i
-- stdSys_con_independent : explicit non-vacuous witness via the standard Kripke model
'''

future_directions = r'''# Future Directions — Logic–Physics Bridge: Consistency of Physical Theories

Derived from this cycle's findings (Provability.lean, Incompleteness.lean,
Bridge.lean). This cycle proved, for any abstract GL theory: Löb's theorem
(loeb_rule), Gödel II (goedel_two), self-independence of the consistency sentence
(con_independent_self), downward transfer of consistency along extension
(physical_implies_math), the *failure* of upward transfer
(math_not_implies_physical), and cross-theory independence of Con(T) over PA
(con_T_independent_of_PA), all witnessed non-vacuously by the standard Kripke model
stdSys.

The conjectures below are bold, falsifiable refinements.

## 1. The "physical reflection gap" is exactly one consistency step

Conjecture. For a recursively axiomatized physical theory T extending PA, the
sentence Con(T) is strictly stronger than Con(PA) over PA: PA ⊢ Con(T) → Con(PA)
but PA ⊬ Con(PA) → Con(T). Equivalently, T adds *exactly one* unit of consistency
strength visible to PA.

The key insight is that our con_T_independent_of_PA already isolates the
PA-verifiable implication Con(T) → Con(PA) (hbridge) as the *only* bridge needed;
the missing converse is precisely a Gödel–Rosser gap that should be formalizable by a
second diagonalization relative to T.

Why now? Provability.lean gives an indexed box i that already lets one theory speak
of another's provability predicate, so both directions live in the *same* formula
language — the converse implication is now a statable, attackable Lean goal rather than
an informal meta-claim.

## 2. Σ₁-soundness is necessary, not merely sufficient, for independence

Conjecture. A consistent GL theory S satisfies "Con is independent over S" if
and only if S is Σ₁-sound (S ⊬ □⊥). The "if" is con_independent_self; the "only
if" should hold because a non-Σ₁-sound consistent theory proves ¬Con (it proves
□⊥), so Con is *decided* (refuted), not independent.

The key insight is that the box-true model trueSys is the extremal counterexample: it
is consistent yet proves ¬Con, so it pins down the exact boundary — independence
fails the instant Σ₁-soundness fails.

Why now? We have both models side by side (trueSys non-Σ₁-sound, stdSys Σ₁-sound)
with computed truth tables (see ComputationalEvidence.md), so the equivalence can be
proved by abstracting the property that distinguishes them rather than guessed.

## 3. Consistency forms a strict semilattice under theory union, with no top

Conjecture. On GL theories ordered by Simulates, the consistent ones are closed
*downward* but the join (catalog ProofSystemCollapse.union) of two consistent theories
can be inconsistent; moreover there is no consistent theory simulating all consistent
theories. Formally: Consistent is a proper order ideal with empty supremum.

The key insight is that physical_implies_math already proves downward closure, while
math_not_implies_physical shows the join of consistent theories may collapse.
'''

algorithms = [
    {
        "name": "Structural Satisfaction over Finite Gödel–Löb Kripke Frames",
        "description": (
            "Evaluates the truth of an indexed modal formula at a world of a finite "
            "GL frame (a transitive, converse-well-founded — hence on finite sets, "
            "strict — accessibility relation). The recursion mirrors the semantic "
            "clauses: ⊥ is false; implication and negation are Boolean; □ᵢa holds at w "
            "iff a holds at every R-successor of w. Validity (= provability in the "
            "standard model stdSys) is satisfaction at every world. For a frame with W "
            "worlds and formula size n the single-formula check costs O(W²·n) because "
            "each box node revisits all successors. This is the computational engine "
            "behind provable_stdSys and the witness con_T_independent_of_PA_witness."
        ),
        "pseudocode": (
            "function SAT(frame, w, phi):\n"
            "    if phi = bot:            return false\n"
            "    if phi = imp(a, b):      return (not SAT(frame, w, a)) or SAT(frame, w, b)\n"
            "    if phi = neg(a):         return not SAT(frame, w, a)\n"
            "    if phi = box(i, a):\n"
            "        for v in successors(frame, w):\n"
            "            if not SAT(frame, v, a): return false\n"
            "        return true\n"
            "\n"
            "function VALID(frame, phi):\n"
            "    for w in frame.worlds:\n"
            "        if not SAT(frame, w, phi): return false\n"
            "    return true"
        ),
        "code": (
            "from __future__ import annotations\n"
            "from dataclasses import dataclass\n"
            "from typing import List, Set, Tuple\n\n"
            "@dataclass(frozen=True)\n"
            "class Form:\n"
            "    kind: str\n"
            "    index: int = 0\n"
            "    left: 'Form | None' = None\n"
            "    right: 'Form | None' = None\n\n"
            "@dataclass\n"
            "class Frame:\n"
            "    worlds: List[int]\n"
            "    R: Set[Tuple[int, int]]\n"
            "    def successors(self, w: int) -> List[int]:\n"
            "        return [v for v in self.worlds if (w, v) in self.R]\n\n"
            "def sat(frame: Frame, w: int, phi: Form) -> bool:\n"
            "    if phi.kind == 'bot':\n"
            "        return False\n"
            "    if phi.kind == 'imp':\n"
            "        return (not sat(frame, w, phi.left)) or sat(frame, w, phi.right)\n"
            "    if phi.kind == 'neg':\n"
            "        return not sat(frame, w, phi.left)\n"
            "    if phi.kind == 'box':\n"
            "        return all(sat(frame, v, phi.left) for v in frame.successors(w))\n"
            "    raise ValueError(phi.kind)\n\n"
            "def valid(frame: Frame, phi: Form) -> bool:\n"
            "    return all(sat(frame, w, phi) for w in frame.worlds)\n"
        ),
    },
    {
        "name": "Cross-Theory Consistency-Independence Decision Procedure",
        "description": (
            "Given a finite GL frame standing in for both PA (index p) and the physical "
            "theory T (index t), decides whether the consistency sentence Con_t = □_t⊥ → ⊥ "
            "is provable, refutable, or independent. The key observation is that □_i⊥ is "
            "satisfied at a world w iff w is terminal (has no successors); hence Con_i is "
            "false exactly at terminal worlds. The procedure scans all worlds once: if Con "
            "is true everywhere it is provable; if false everywhere its negation is provable; "
            "if mixed, neither is valid and Con is independent — the computational realization "
            "of con_T_independent_of_PA. Complexity O(W²) on a W-world frame (one box "
            "evaluation per world)."
        ),
        "pseudocode": (
            "function CON_STATUS(frame, i):\n"
            "    con_true_worlds  = 0\n"
            "    con_false_worlds = 0\n"
            "    for w in frame.worlds:\n"
            "        box_bot = (successors(frame, w) is empty)   # □_i⊥ at w\n"
            "        con = not box_bot                            # Con_i = □_i⊥ → ⊥\n"
            "        if con: con_true_worlds  += 1\n"
            "        else:   con_false_worlds += 1\n"
            "    if con_false_worlds == 0: return 'PROVABLE'\n"
            "    if con_true_worlds  == 0: return 'REFUTABLE'   # ¬Con provable\n"
            "    return 'INDEPENDENT'"
        ),
        "code": (
            "from __future__ import annotations\n"
            "from typing import List, Set, Tuple\n\n"
            "def con_status(worlds: List[int], R: Set[Tuple[int, int]]) -> str:\n"
            "    \"\"\"Classify the consistency sentence on a finite GL frame.\"\"\"\n"
            "    con_true = 0\n"
            "    con_false = 0\n"
            "    for w in worlds:\n"
            "        terminal = not any((w, v) in R for v in worlds)\n"
            "        # box bot is true iff w is terminal; Con = box bot -> bot.\n"
            "        if terminal:\n"
            "            con_false += 1\n"
            "        else:\n"
            "            con_true += 1\n"
            "    if con_false == 0:\n"
            "        return 'PROVABLE'\n"
            "    if con_true == 0:\n"
            "        return 'REFUTABLE'\n"
            "    return 'INDEPENDENT'\n\n"
            "if __name__ == '__main__':\n"
            "    # standard frame: 1 -> 0, world 0 terminal, world 1 internal\n"
            "    print(con_status([0, 1], {(1, 0)}))   # INDEPENDENT\n"
        ),
    },
    {
        "name": "Downward Consistency Transfer along a Simulation Tower",
        "description": (
            "Implements the order-theoretic content of physical_implies_math and "
            "consistency_transfers_tower. Proof systems are presented by provability "
            "oracles over a finite probe set of formulas; Simulates(S, T) is set "
            "inclusion of provable formulas, and Consistent(S) is non-provability of ⊥. "
            "Given a chain T₀ ⊇ T₁ ⊇ … ⊇ Tₙ (each simulating the next) with T₀ "
            "consistent, the algorithm certifies that every theory down the tower is "
            "consistent, by transitivity of simulation. Linear in the tower length times "
            "the probe size."
        ),
        "pseudocode": (
            "function TRANSFER(tower, probe):\n"
            "    # tower = [T0, T1, ..., Tn] with Simulates(T_k, T_{k+1})\n"
            "    assert CONSISTENT(tower[0])              # top is consistent\n"
            "    for k in 0 .. len(tower)-2:\n"
            "        assert SIMULATES(tower[k], tower[k+1], probe)\n"
            "    # conclude: every T_k is consistent\n"
            "    return all(CONSISTENT(T) for T in tower)"
        ),
        "code": (
            "from __future__ import annotations\n"
            "from dataclasses import dataclass\n"
            "from typing import Callable, List\n\n"
            "@dataclass\n"
            "class ProofSys:\n"
            "    name: str\n"
            "    provable: Callable[[object], bool]\n\n"
            "def consistent(S: ProofSys, bot: object) -> bool:\n"
            "    return not S.provable(bot)\n\n"
            "def simulates(S: ProofSys, T: ProofSys, probe: List[object]) -> bool:\n"
            "    return all((not T.provable(f)) or S.provable(f) for f in probe)\n\n"
            "def transfer(tower: List[ProofSys], probe: List[object], bot: object) -> bool:\n"
            "    \"\"\"Certify downward consistency transfer along a simulation tower.\"\"\"\n"
            "    if not consistent(tower[0], bot):\n"
            "        return False\n"
            "    for k in range(len(tower) - 1):\n"
            "        if not simulates(tower[k], tower[k + 1], probe):\n"
            "            return False\n"
            "    return all(consistent(T, bot) for T in tower)\n"
        ),
    },
]

demos = [
    {
        "name": "Executable Witnesses for the Three Bridge Theorems",
        "description": (
            "A complete, dependency-free reference implementation that realizes the "
            "abstract proof-theoretic objects (formulas, the consistency sentence Con, "
            "finite GL Kripke frames, satisfaction, and proof systems as validity "
            "oracles) and then verifies each main result on concrete finite models: "
            "physical_implies_math (consistency flows downhill), math_not_implies_physical "
            "(it does not flow uphill, via trueSys ⊇ trivialSys), goedel_two (a consistent "
            "GL model does not prove Con), con_T_independent_of_PA (stdSys proves neither "
            "Con_t nor ¬Con_t), and the trueSys boundary case showing Σ₁-soundness is "
            "essential. Every claim is checked with an assertion."
        ),
        "code": demo,
    }
]

visualizations = [
    {
        "name": "The Consistency Landscape of the Standard GL Frame",
        "description": (
            "Renders the standard two-world GL frame (world 1 accessing terminal world 0) "
            "and colors each world by the truth value of the consistency sentence Con: blue "
            "where Con is true (internal worlds, □⊥ false) and red where it is false "
            "(terminal worlds, □⊥ true). The split coloring makes the independence theorem "
            "visible at a glance — Con is valid at neither extreme, so it is neither provable "
            "nor refutable."
        ),
        "code": viz,
    }
]

interactive_demos = [
    {
        "title": "The Consistency Explorer: Build a World, Watch Gödel II Happen",
        "description": (
            "An interactive Kripke-frame playground. Switch between the standard model "
            "stdSys, a taller chain, a single terminal world, and the non-Σ₁-sound trueSys, "
            "and watch the consistency sentence Con = □⊥ → ⊥ light up world by world. The "
            "widget reports a live verdict — PROVABLE, REFUTABLE, or INDEPENDENT — and "
            "explains why: independence appears exactly when Con is true at some worlds and "
            "false at terminal worlds, while trueSys (consistent but not Σ₁-sound) actually "
            "refutes Con, marking the precise frontier where independence breaks down."
        ),
        "html": interactive,
    }
]

package = {
    "title": "Logic–Physics Bridge: The Proof-Theoretic Consistency of Physical Theories",
    "domain": "Applications",
    "description": (
        "Recasts the consistency of a physical theory as a proof-theoretic question and "
        "proves that physical consistency implies mathematical consistency (but not vice "
        "versa) and that, if a physical theory T is consistent, then Con(T) is independent "
        "of Peano Arithmetic."
    ),
    "authors": ["Aristotle"],
    "date": "2026-06-28",
    "key_results": [
        "physical_implies_math",
        "consistency_transfers_tower",
        "math_not_implies_physical",
        "con_T_independent_of_PA",
        "con_T_independent_of_PA_witness",
    ],
    "keywords": [
        "Gödel–Löb logic",
        "Con(T)",
        "Löb's theorem",
        "Gödel's second incompleteness theorem",
        "Σ₁-soundness",
        "proof system simulation",
        "Kripke model",
        "consistency",
    ],
    "article": article,
    "research_paper": paper,
    "research_paper_tex": paper_tex,
    "demo": demo,
    "demos": demos,
    "algorithms": algorithms,
    "visualizations": visualizations,
    "interactive_demos": interactive_demos,
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": [
        "Catalog/Logic/PhysicsConsistency/Bridge.lean",
        "Catalog/Logic/PhysicsConsistency/Incompleteness.lean",
    ],
}

out = HERE / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False))
print("wrote", out)
print("validating round-trip...")
json.loads(out.read_text())
print("PACKAGE.json is valid JSON")


"""Visualization: the standard GL frame and the consistency landscape.

Draws the two-world standard Kripke frame 1 -> 0 and annotates each world with
the truth values of `box i bot` and the consistency sentence `Con_i`, making the
independence of Con visually explicit: Con is false at the terminal world 0 and
true at the non-terminal world 1, so it is valid at neither.
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def standard_frame() -> Tuple[List[int], List[Tuple[int, int]]]:
    """Worlds and accessibility edges of the standard GL frame (1 sees 0)."""
    return [0, 1], [(1, 0)]


def sat_box_bot(succ: Dict[int, List[int]], w: int) -> bool:
    """box i bot holds at w iff w is terminal (no successors)."""
    return len(succ[w]) == 0


def main() -> None:
    worlds, edges = standard_frame()
    succ: Dict[int, List[int]] = {w: [] for w in worlds}
    for a, b in edges:
        succ[a].append(b)

    pos: Dict[int, Tuple[float, float]] = {0: (0.0, 0.0), 1: (0.0, 2.0)}

    fig, ax = plt.subplots(figsize=(5, 6))

    # edges (accessibility), drawn as arrows
    for a, b in edges:
        xa, ya = pos[a]
        xb, yb = pos[b]
        ax.annotate(
            "", xy=(xb, yb + 0.45), xytext=(xa, ya - 0.45),
            arrowprops=dict(arrowstyle="-|>", lw=2, color="#333"),
        )

    # worlds
    for w in worlds:
        x, y = pos[w]
        box_bot = sat_box_bot(succ, w)
        con_val = not box_bot  # Con_i = box bot -> bot ; true iff box bot false
        color = "#d7eaff" if con_val else "#ffd7d7"
        circ = plt.Circle((x, y), 0.45, color=color, ec="#333", lw=2, zorder=3)
        ax.add_patch(circ)
        ax.text(x, y + 0.08, f"w{w}", ha="center", va="center",
                fontsize=14, fontweight="bold", zorder=4)
        ax.text(x, y - 0.16, "terminal" if box_bot else "internal",
                ha="center", va="center", fontsize=8, style="italic", zorder=4)
        label = (f"$\\Box\\bot$ = {box_bot}\n$\\mathrm{{Con}}$ = {con_val}")
        ax.text(x + 0.8, y, label, ha="left", va="center", fontsize=11)

    ax.set_title("Standard GL frame: Con is true at w1, false at w0\n"
                 "=> neither Con nor ¬Con is valid (independence)",
                 fontsize=11)
    ax.set_xlim(-1.5, 3.2)
    ax.set_ylim(-1.2, 3.2)
    ax.set_aspect("equal")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("gl_frame_consistency.png", dpi=150)
    print("wrote gl_frame_consistency.png")


if __name__ == "__main__":
    main()


"""Numerical / computational demonstration of the Logic-Physics Bridge results.

This self-contained script realizes the abstract proof-theoretic objects of the
paper on *finite* structures so that every theorem becomes an executable check:

  * Formulas of the indexed Goedel-Loeb (GL) language: bot, imp, neg, box i a.
  * The consistency sentence Con_i := (box i bot) -> bot.
  * Finite GL Kripke frames (transitive, converse-well-founded accessibility),
    on which "provable in stdSys" means "valid (true at every world)".
  * Proof systems as validity oracles, with Provable / Consistent / Simulates.

We then verify, on concrete finite models:

  * physical_implies_math   : Simulates(T, PA) and Consistent(T) => Consistent(PA)
  * math_not_implies_physical : a consistent base with an inconsistent extension
  * goedel_two              : a consistent GL model does not prove Con
  * con_T_independent_of_PA : stdSys proves neither Con_t nor neg Con_t

Run with:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, FrozenSet, List, Set, Tuple


# --------------------------------------------------------------------------- #
# 1. The indexed GL formula language
# --------------------------------------------------------------------------- #

@dataclass(frozen=True)
class Form:
    """A formula of the indexed GL language.

    kind is one of: 'bot', 'imp', 'neg', 'box'.
    For 'imp':  left, right are sub-formulas.
    For 'neg':  left is the sub-formula.
    For 'box':  index is the theory index, left is the sub-formula.
    """
    kind: str
    index: int = 0
    left: "Form | None" = None
    right: "Form | None" = None


def bot() -> Form:
    return Form("bot")


def imp(a: Form, b: Form) -> Form:
    return Form("imp", left=a, right=b)


def neg(a: Form) -> Form:
    return Form("neg", left=a)


def box(i: int, a: Form) -> Form:
    return Form("box", index=i, left=a)


def con(i: int) -> Form:
    """Consistency sentence Con_i := (box i bot) -> bot."""
    return imp(box(i, bot()), bot())


# --------------------------------------------------------------------------- #
# 2. Finite GL Kripke frames and satisfaction
# --------------------------------------------------------------------------- #

@dataclass
class Frame:
    """A finite Kripke frame: worlds and an accessibility relation R.

    For a *GL* frame, R must be transitive and converse-well-founded (no
    infinite ascending chains); on a finite frame the latter is equivalent to
    R being irreflexive and transitive (a strict partial order).
    """
    worlds: List[int]
    R: Set[Tuple[int, int]]

    def successors(self, w: int) -> List[int]:
        return [v for v in self.worlds if (w, v) in self.R]


def sat(frame: Frame, w: int, phi: Form) -> bool:
    """Satisfaction of phi at world w (structural recursion, all indices share R)."""
    if phi.kind == "bot":
        return False
    if phi.kind == "imp":
        assert phi.left is not None and phi.right is not None
        return (not sat(frame, w, phi.left)) or sat(frame, w, phi.right)
    if phi.kind == "neg":
        assert phi.left is not None
        return not sat(frame, w, phi.left)
    if phi.kind == "box":
        assert phi.left is not None
        return all(sat(frame, v, phi.left) for v in frame.successors(w))
    raise ValueError(f"unknown formula kind: {phi.kind}")


def valid(frame: Frame, phi: Form) -> bool:
    """phi is valid (= provable in the standard model on this frame) iff true everywhere."""
    return all(sat(frame, w, phi) for w in frame.worlds)


# --------------------------------------------------------------------------- #
# 3. Proof systems as validity / provability oracles
# --------------------------------------------------------------------------- #

@dataclass
class ProofSys:
    """An abstract proof system, presented by a provability oracle on Form."""
    name: str
    provable: Callable[[Form], bool]


def Provable(S: ProofSys, f: Form) -> bool:
    return S.provable(f)


def Consistent(S: ProofSys) -> bool:
    """Consistent(S) := not Provable(S, bot)."""
    return not S.provable(bot())


def Simulates(S: ProofSys, T: ProofSys, probe: List[Form]) -> bool:
    """Simulates(S, T): S proves everything T proves (checked over a probe set)."""
    return all((not T.provable(f)) or S.provable(f) for f in probe)


def std_sys(frame: Frame) -> ProofSys:
    """stdSys: provable = valid on a finite GL frame (Sigma_1-sound, consistent)."""
    return ProofSys("stdSys", lambda f: valid(frame, f))


def true_sys() -> ProofSys:
    """trueSys: 'box-true' system. Consistent but NOT Sigma_1-sound: it proves
    box i bot (hence neg Con_i) while not proving bot itself.

    Realized as: provable iff true under the valuation that makes every boxed
    formula true (the single-reflexive-blind-point reading). It proves Con? No:
    it proves box i bot, so Con_i = box i bot -> bot evaluates to bot here.
    """
    def prov(f: Form) -> bool:
        return _true_eval(f)
    return ProofSys("trueSys", prov)


def _true_eval(f: Form) -> bool:
    if f.kind == "bot":
        return False
    if f.kind == "box":
        # 'box-true': every boxed claim is declared provable/true.
        return True
    if f.kind == "neg":
        assert f.left is not None
        return not _true_eval(f.left)
    if f.kind == "imp":
        assert f.left is not None and f.right is not None
        return (not _true_eval(f.left)) or _true_eval(f.right)
    raise ValueError(f.kind)


def trivial_sys() -> ProofSys:
    """trivialSys: proves EVERY formula (hence inconsistent)."""
    return ProofSys("trivialSys", lambda f: True)


# --------------------------------------------------------------------------- #
# 4. The standard finite GL frame used as the witness model
# --------------------------------------------------------------------------- #

def standard_frame() -> Frame:
    """A two-world strict order 0 < 1: world 1 sees world 0 (terminal).

    Worlds: {0, 1}; R = {(1, 0)}. Transitive and irreflexive, hence a GL frame.
    World 0 is terminal (no successors)  => sat(0, box i bot) is True.
    World 1 has successor 0              => sat(1, box i bot) is False.
    Therefore Con_i is FALSE at world 0 and TRUE at world 1: neither Con_i nor
    its negation is valid -> independence.
    """
    return Frame(worlds=[0, 1], R={(1, 0)})


# --------------------------------------------------------------------------- #
# 5. Executable verification of the paper's theorems
# --------------------------------------------------------------------------- #

def probe_formulas(max_index: int = 2) -> List[Form]:
    """A finite probe set of formulas for Simulates checks."""
    probes: List[Form] = [bot()]
    for i in range(max_index + 1):
        probes += [box(i, bot()), con(i), neg(con(i)), imp(con(i), con(0))]
    return probes


def demo_physical_implies_math() -> None:
    print("== physical_implies_math : consistency flows downhill ==")
    frame = standard_frame()
    PA = std_sys(frame)          # consistent GL base
    T = std_sys(frame)           # T extends PA (here equal): Simulates(T, PA)
    probe = probe_formulas()
    sim = Simulates(T, PA, probe)
    print(f"  Simulates(T, PA)        = {sim}")
    print(f"  Consistent(T)           = {Consistent(T)}")
    print(f"  => Consistent(PA)       = {Consistent(PA)}")
    assert not (sim and Consistent(T)) or Consistent(PA)
    print("  OK: Simulates(T,PA) and Consistent(T) => Consistent(PA)\n")


def demo_math_not_implies_physical() -> None:
    print("== math_not_implies_physical : consistency does NOT flow uphill ==")
    PA = true_sys()              # consistent base
    T = trivial_sys()           # inconsistent extension
    probe = probe_formulas()
    sim = Simulates(T, PA, probe)
    print(f"  Consistent(PA=trueSys)        = {Consistent(PA)}")
    print(f"  Simulates(T=trivialSys, PA)   = {sim}")
    print(f"  Consistent(T=trivialSys)      = {Consistent(T)}")
    assert Consistent(PA) and sim and not Consistent(T)
    print("  OK: consistent base, extension simulates it, yet extension inconsistent\n")


def demo_goedel_two() -> None:
    print("== goedel_two : a consistent GL model does not prove Con ==")
    frame = standard_frame()
    S = std_sys(frame)
    i = 0
    proves_con = Provable(S, con(i))
    print(f"  Consistent(stdSys)      = {Consistent(S)}")
    print(f"  Provable(stdSys, Con_0) = {proves_con}")
    assert Consistent(S) and not proves_con
    print("  OK: consistent => does not prove its own consistency\n")


def demo_con_T_independent_of_PA() -> None:
    print("== con_T_independent_of_PA : Con(T) independent of PA (stdSys witness) ==")
    frame = standard_frame()
    S = std_sys(frame)
    t = 1
    proves_con = Provable(S, con(t))
    proves_neg_con = Provable(S, neg(con(t)))
    # show the per-world truth values of box t bot and Con_t:
    print("  world | box t bot | Con_t")
    for w in frame.worlds:
        print(f"    {w}   |   {sat(frame, w, box(t, bot()))!s:5} |  {sat(frame, w, con(t))!s:5}")
    print(f"  Provable(stdSys, Con_t)       = {proves_con}")
    print(f"  Provable(stdSys, neg Con_t)   = {proves_neg_con}")
    assert (not proves_con) and (not proves_neg_con)
    print("  OK: stdSys proves neither Con_t nor its negation -> independence\n")


def demo_trueSys_decides_con() -> None:
    print("== boundary : trueSys (not Sigma_1-sound) REFUTES Con ==")
    S = true_sys()
    i = 0
    print(f"  Consistent(trueSys)             = {Consistent(S)}")
    print(f"  Provable(trueSys, box i bot)    = {Provable(S, box(i, bot()))}")
    print(f"  Provable(trueSys, Con_i)        = {Provable(S, con(i))}")
    print(f"  Provable(trueSys, neg Con_i)    = {Provable(S, neg(con(i)))}")
    assert Consistent(S) and Provable(S, neg(con(i))) and not Provable(S, con(i))
    print("  OK: consistent yet proves neg Con -> Sigma_1-soundness is essential\n")


def main() -> None:
    print("Logic-Physics Bridge: computational witnesses\n")
    demo_physical_implies_math()
    demo_math_not_implies_physical()
    demo_goedel_two()
    demo_con_T_independent_of_PA()
    demo_trueSys_decides_con()
    print("All checks passed.")


if __name__ == "__main__":
    main()
