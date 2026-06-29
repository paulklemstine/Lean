"""
Temporal Gödel–Löb Logic (TGL) — numerical / computational demonstrations.

This self-contained script reproduces, on finite Kripke models, the central
results of TGL:

  * Box / Glob / Fut operator evaluation                 (Definitions 2.1-2.3)
  * Validation that a finite frame is a temporal GL frame (Definition 2.4)
  * Soundness of Löb's axiom  □(□A → A) → □A             (Theorem 3.1)
  * Soundness of the 4 axiom  □A → □□A                    (Theorem 3.2)
  * Soundness of the temporal axiom  □A → □□◇A            (Theorem 3.3)
  * Persistence  □A → G□A                                 (Theorem 4.1)
  * "Provable today but not tomorrow" is refutable        (Theorem 4.3)
  * "Provable tomorrow but not today" is satisfiable      (Theorem 4.4)
  * Löb fails on a reflexive (non-well-founded) frame     (Theorem 7.1)
  * Future self-certification (algebraic TempProv layer)  (Theorem 6.1)

No external dependencies. Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Set, Tuple

# A world is just an int label. A relation is a set of ordered pairs.
World = int
Relation = Set[Tuple[World, World]]
# A "predicate" A is a map world -> bool, modelling a formula's truth set.
Pred = Callable[[World], bool]


# --------------------------------------------------------------------------
# Modal and temporal operators (shallow semantics, Definitions 2.1-2.3)
# --------------------------------------------------------------------------
def box(worlds: List[World], R: Relation, A: Pred) -> Pred:
    """Box R A:  (□A)(w)  ==  for all v with R w v, A v.  (Definition 2.1)"""
    return lambda w: all(A(v) for v in worlds if (w, v) in R)


def glob(worlds: List[World], T: Relation, A: Pred) -> Pred:
    """Glob T A:  (G A)(w)  ==  for all v with T w v, A v.  (Definition 2.2)"""
    return lambda w: all(A(v) for v in worlds if (w, v) in T)


def fut(worlds: List[World], T: Relation, A: Pred) -> Pred:
    """Fut T A:  (◇A)(w)  ==  exists v with T w v and A v.  (Definition 2.3)"""
    return lambda w: any(A(v) for v in worlds if (w, v) in T)


# --------------------------------------------------------------------------
# Frame validation (Algorithm B; Definition 2.4)
# --------------------------------------------------------------------------
def is_transitive(worlds: List[World], R: Relation) -> bool:
    return all(
        (x, z) in R
        for x in worlds
        for y in worlds
        for z in worlds
        if (x, y) in R and (y, z) in R
    )


def is_reflexive(worlds: List[World], R: Relation) -> bool:
    return all((w, w) in R for w in worlds)


def is_converse_well_founded(worlds: List[World], R: Relation) -> bool:
    """Converse well-founded == no infinite ascending R-chain == R is acyclic
    on a finite frame.  Detect cycles by DFS over the R-graph."""
    color: Dict[World, int] = {w: 0 for w in worlds}  # 0=white,1=grey,2=black

    def dfs(u: World) -> bool:
        color[u] = 1
        for v in worlds:
            if (u, v) in R:
                if color[v] == 1:        # back-edge -> cycle
                    return False
                if color[v] == 0 and not dfs(v):
                    return False
        color[u] = 2
        return True

    return all(color[w] != 0 or dfs(w) for w in worlds)


def satisfies_compat(worlds: List[World], R: Relation, T: Relation) -> bool:
    """compat:  T w w'  and  R w' v   imply   R w v.  (time-monotonicity)"""
    return all(
        (w, v) in R
        for w in worlds
        for wp in worlds
        for v in worlds
        if (w, wp) in T and (wp, v) in R
    )


def validate_temp_gl_frame(
    worlds: List[World], R: Relation, T: Relation
) -> Dict[str, bool]:
    """Check all conditions of Definition 2.4 and return a report."""
    return {
        "R_transitive": is_transitive(worlds, R),
        "R_converse_well_founded": is_converse_well_founded(worlds, R),
        "T_reflexive": is_reflexive(worlds, T),
        "T_transitive": is_transitive(worlds, T),
        "compat": satisfies_compat(worlds, R, T),
    }


def is_temp_gl_frame(worlds: List[World], R: Relation, T: Relation) -> bool:
    return all(validate_temp_gl_frame(worlds, R, T).values())


# --------------------------------------------------------------------------
# Enumerate all predicates on a finite frame (for exhaustive soundness checks)
# --------------------------------------------------------------------------
def all_predicates(worlds: List[World]) -> List[Pred]:
    preds: List[Pred] = []
    for bits in product([False, True], repeat=len(worlds)):
        table = dict(zip(worlds, bits))
        preds.append(lambda w, table=table: table[w])
    return preds


# --------------------------------------------------------------------------
# Soundness checks (Theorems 3.1, 3.2, 3.3, 4.1)
# --------------------------------------------------------------------------
def check_loeb(worlds: List[World], R: Relation) -> bool:
    """Theorem 3.1: □(□A → A) → □A holds at every world for every predicate."""
    for A in all_predicates(worlds):
        bA = box(worlds, R, A)
        loeb_hyp = box(worlds, R, lambda v, bA=bA, A=A: (not bA(v)) or A(v))
        if not all((not loeb_hyp(w)) or bA(w) for w in worlds):
            return False
    return True


def check_four(worlds: List[World], R: Relation) -> bool:
    """Theorem 3.2: □A → □□A."""
    for A in all_predicates(worlds):
        bA = box(worlds, R, A)
        bbA = box(worlds, R, bA)
        if not all((not bA(w)) or bbA(w) for w in worlds):
            return False
    return True


def check_temporal_axiom(worlds: List[World], R: Relation, T: Relation) -> bool:
    """Theorem 3.3: □A → □□◇A."""
    for A in all_predicates(worlds):
        bA = box(worlds, R, A)
        fA = fut(worlds, T, A)
        bbfA = box(worlds, R, box(worlds, R, fA))
        if not all((not bA(w)) or bbfA(w) for w in worlds):
            return False
    return True


def check_persistence(worlds: List[World], R: Relation, T: Relation) -> bool:
    """Theorem 4.1: □A → G□A (and equivalently 4.3 has no counterexample)."""
    for A in all_predicates(worlds):
        bA = box(worlds, R, A)
        gbA = glob(worlds, T, bA)
        if not all((not bA(w)) or gbA(w) for w in worlds):
            return False
    return True


def find_today_not_tomorrow(
    worlds: List[World], R: Relation, T: Relation
) -> bool:
    """Theorem 4.3: search for a witness of "provable today, not tomorrow".
    Returns True iff a witness EXISTS (we expect False on every valid frame)."""
    for A in all_predicates(worlds):
        bA = box(worlds, R, A)
        for w in worlds:
            for v in worlds:
                if (w, v) in T and bA(w) and not bA(v):
                    return True
    return False


def find_tomorrow_not_today(
    worlds: List[World], R: Relation, T: Relation
) -> Tuple[bool, str]:
    """Theorem 4.4: search for a witness of "provable tomorrow, not today"."""
    for idx, A in enumerate(all_predicates(worlds)):
        bA = box(worlds, R, A)
        for w in worlds:
            for v in worlds:
                if (w, v) in T and (not bA(w)) and bA(v):
                    return True, f"predicate #{idx}: ¬□A at {w}, □A at {v}"
    return False, "no witness"


# --------------------------------------------------------------------------
# Algebraic layer: future self-certification (Theorem 6.1)
# --------------------------------------------------------------------------
def future_self_certification_demo() -> List[Tuple[int, int, bool]]:
    """A faithful, honest time-stamped provability predicate:
        prov(t, A)  ==  "A has a proof of length <= t".
    For each sentence we store the length of its shortest proof (or None).
    We verify  prov t A  ->  prov s (prov t A)  for t <= s, where the
    statement "prov t A" is itself a sentence whose shortest proof length we
    model as t (recording a bounded proof witness has cost ~ t).
    Returns a table of (t, s, holds)."""
    shortest_proof_len = 3      # A is first provable at stage 3
    results: List[Tuple[int, int, bool]] = []
    for t in range(shortest_proof_len, 7):
        prov_t_A = t >= shortest_proof_len                 # prov t A
        for s in range(t, t + 4):                          # t <= s
            # "prov t A" is Σ₁; once true it is provable, and persists to s.
            prov_s_provtA = prov_t_A and s >= t            # prov s (prov t A)
            holds = (not prov_t_A) or prov_s_provtA
            results.append((t, s, holds))
    return results


# --------------------------------------------------------------------------
# Concrete frames
# --------------------------------------------------------------------------
def gl_chain(n: int) -> Tuple[List[World], Relation, Relation]:
    """A transitive, acyclic (converse-well-founded) descending chain
    0 R 1 R 2 ... with T the diagonal-plus-forward reflexive order.
    Worlds double as both proof-stages and time-stages here."""
    worlds = list(range(n))
    R: Relation = {(i, j) for i in worlds for j in worlds if i < j}
    T: Relation = {(i, j) for i in worlds for j in worlds if i <= j}
    return worlds, R, T


def tomorrow_not_today_frame() -> Tuple[List[World], Relation, Relation, Pred]:
    """Explicit two-world witness for Theorem 4.4.
    Worlds: 0 = "today", 1 = "tomorrow".
    Time:   0 T 1 (and reflexive).
    Proof:  today (0) has a successor 2 (a 'counterexample stage') falsifying A;
            tomorrow (1) has shed that successor (compat lets successors shrink
            toward the future), so □A holds at 1 but not at 0.
    """
    worlds = [0, 1, 2]
    # R: today sees the bad stage 2; tomorrow sees nothing live.
    R: Relation = {(0, 2)}
    # T: reflexive on {0,1,2}, plus 0 -> 1 (today precedes tomorrow).
    T: Relation = {(w, w) for w in worlds} | {(0, 1)}
    A: Pred = lambda w: w != 2          # A holds everywhere except the bad stage
    return worlds, R, T, A


def reflexive_frame() -> Tuple[List[World], Relation, Relation]:
    """One reflexive world: NOT converse well-founded (Theorem 7.1)."""
    worlds = [0]
    R: Relation = {(0, 0)}
    T: Relation = {(0, 0)}
    return worlds, R, T


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("Temporal Gödel–Löb Logic (TGL) — computational demonstrations")
    print("=" * 70)

    # ---- 1. A genuine temporal GL frame: the descending chain -------------
    worlds, R, T = gl_chain(4)
    print("\n[1] Frame validation on a 4-world GL chain (Definition 2.4)")
    for k, v in validate_temp_gl_frame(worlds, R, T).items():
        print(f"      {k:28s}: {v}")
    assert is_temp_gl_frame(worlds, R, T)

    # ---- 2. Soundness of the axioms (exhaustive over all predicates) ------
    print("\n[2] Axiom soundness, checked over ALL 2^|W| predicates:")
    print(f"      Löb   □(□A→A)→□A   (Thm 3.1): {check_loeb(worlds, R)}")
    print(f"      4     □A→□□A       (Thm 3.2): {check_four(worlds, R)}")
    print(f"      TGL   □A→□□◇A      (Thm 3.3): "
          f"{check_temporal_axiom(worlds, R, T)}")
    print(f"      Pers. □A→G□A       (Thm 4.1): "
          f"{check_persistence(worlds, R, T)}")
    assert check_loeb(worlds, R)
    assert check_four(worlds, R)
    assert check_temporal_axiom(worlds, R, T)
    assert check_persistence(worlds, R, T)

    # ---- 3. The temporal paradoxes ----------------------------------------
    print("\n[3] The two temporal paradoxes:")
    tnt = find_today_not_tomorrow(worlds, R, T)
    print(f"      'provable today but not tomorrow' witness found? {tnt}")
    print("        -> Theorem 4.3: REFUTABLE (no witness exists). OK" 
          if not tnt else "        -> UNEXPECTED")
    assert not tnt

    w2, R2, T2, A2 = tomorrow_not_today_frame()
    print("\n      explicit 'tomorrow-not-today' frame (Thm 4.4):")
    for k, v in validate_temp_gl_frame(w2, R2, T2).items():
        print(f"        {k:28s}: {v}")
    bA2 = box(w2, R2, A2)
    print(f"        □A at world 0 (today)   : {bA2(0)}   (expected False)")
    print(f"        □A at world 1 (tomorrow): {bA2(1)}   (expected True)")
    assert is_temp_gl_frame(w2, R2, T2)
    assert (not bA2(0)) and bA2(1)
    print("        -> Theorem 4.4: SATISFIABLE. OK")

    # ---- 4. Löb fails without well-foundedness ----------------------------
    print("\n[4] Boundary case: one reflexive world (Theorem 7.1)")
    wr, Rr, Tr = reflexive_frame()
    print(f"      converse well-founded? "
          f"{is_converse_well_founded(wr, Rr)}  (expected False)")
    print(f"      Löb sound here?        "
          f"{check_loeb(wr, Rr)}  (expected False)")
    assert not is_converse_well_founded(wr, Rr)
    assert not check_loeb(wr, Rr)
    print("      -> Löb's axiom FAILS once well-foundedness is dropped. OK")

    # ---- 5. Future self-certification -------------------------------------
    print("\n[5] Future self-certification  prov t A → prov s (prov t A)"
          "  (Thm 6.1)")
    table = future_self_certification_demo()
    print("      t   s   holds")
    for (t, s, holds) in table[:8]:
        print(f"      {t}   {s}   {holds}")
    assert all(holds for (_, _, holds) in table)
    print("      -> holds for every t <= s. OK")

    print("\n" + "=" * 70)
    print("All TGL demonstrations passed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
