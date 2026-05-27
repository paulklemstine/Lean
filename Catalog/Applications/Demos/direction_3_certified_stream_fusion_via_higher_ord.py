#!/usr/bin/env python3
"""
Applications of Certified Stream Fusion

Demonstrates real-world applications of the stream fusion theory:
1. GHC-style pipeline optimization
2. Cost analysis of fusion
3. Compiler optimization verification
"""

from algorithms import (
    Term, TermKind, var, stream, unstream, smap, sfilter, comp, foldr,
    pretty, admin_count, has_redex, complete_reduction, normalize_with_trace,
    term_size
)


def application_1_pipeline_optimization():
    """
    Application 1: GHC-style Pipeline Optimization

    In GHC, list operations are defined as:
      map f xs  =  unstream (smap f (stream xs))
      filter p xs  =  unstream (sfilter p (stream xs))

    When composed, intermediate stream/unstream pairs appear:
      map f (filter p xs)
      = unstream (smap f (stream (unstream (sfilter p (stream xs)))))

    Fusion eliminates the intermediate pair, giving:
      unstream (smap f (sfilter p (stream xs)))

    This saves one allocation/deallocation cycle per element.
    """
    print("=" * 60)
    print("Application 1: GHC-Style Pipeline Optimization")
    print("=" * 60)

    xs = var(0)
    f = var(1)
    g = var(2)
    p = var(3)

    # Simulate GHC's RULES-based fusion
    pipelines = [
        ("map f xs", unstream(smap(f, stream(xs)))),
        ("map f (map g xs)",
         unstream(smap(f, stream(unstream(smap(g, stream(xs))))))),
        ("map f (filter p xs)",
         unstream(smap(f, stream(unstream(sfilter(p, stream(xs))))))),
        ("map f (map g (filter p xs))",
         unstream(smap(f, stream(unstream(smap(g, stream(
             unstream(sfilter(p, stream(xs)))))))))),
    ]

    for name, term in pipelines:
        nf, trace = normalize_with_trace(term)
        orig_admin = admin_count(term)
        fused_admin = admin_count(nf)
        savings = orig_admin - fused_admin

        print(f"\n  Pipeline: {name}")
        print(f"    Before:  {pretty(term)}")
        print(f"    After:   {pretty(nf)}")
        print(f"    Admin:   {orig_admin} → {fused_admin} (saved {savings})")
        print(f"    Steps:   {len(trace) - 1}")

        # Cost analysis: each admin node = one allocation
        allocs_saved = savings  # each stream/unstream = 1 allocation
        if len(trace) > 1:
            print(f"    Allocs saved per element: {allocs_saved}")

    print()


def application_2_cost_analysis():
    """
    Application 2: Cost Analysis

    The adminCount metric provides a rigorous upper bound on the
    number of intermediate data structure operations. The formal
    theorem fusion_step_admin_decrease guarantees each step saves ≥ 2.
    """
    print("=" * 60)
    print("Application 2: Fusion Cost Analysis")
    print("=" * 60)

    xs = var(0)
    f = var(1)

    # Build increasingly deep pipelines
    print("\n  Pipeline depth vs. fusion savings:\n")
    print(f"  {'Depth':<8} {'Admin Before':<15} {'Admin After':<15} {'Saved':<10} {'Steps':<8}")
    print(f"  {'-'*56}")

    for depth in range(1, 8):
        # Build: map f (map f (... (map f xs) ...)) with `depth` maps
        term = xs
        for _ in range(depth):
            term = unstream(smap(f, stream(term)))

        nf, trace = normalize_with_trace(term)
        before = admin_count(term)
        after = admin_count(nf)
        saved = before - after
        steps = len(trace) - 1

        print(f"  {depth:<8} {before:<15} {after:<15} {saved:<10} {steps:<8}")

    print()
    print("  Key insight: admin cost grows as 2*depth, but fused form")
    print("  always has admin cost 2 (one stream + one unstream at edges).")
    print("  Theorem guarantees each step saves ≥ 2 admin nodes.")
    print()


def application_3_verification():
    """
    Application 3: Compiler Optimization Verification

    Verify that specific GHC RULES are correct by checking that
    fusion preserves extensional behavior on test data.
    """
    print("=" * 60)
    print("Application 3: Compiler Optimization Verification")
    print("=" * 60)

    # Define concrete evaluation model
    def eval_term(t, env):
        if t.kind == TermKind.VAR:
            return env[t.var_id]
        elif t.kind == TermKind.STREAM:
            return eval_term(t.children[0], env)  # identity
        elif t.kind == TermKind.UNSTREAM:
            return eval_term(t.children[0], env)  # identity
        elif t.kind == TermKind.SMAP:
            f = eval_term(t.children[0], env)
            xs = eval_term(t.children[1], env)
            return [f(x) for x in xs]
        elif t.kind == TermKind.SFILTER:
            p = eval_term(t.children[0], env)
            xs = eval_term(t.children[1], env)
            return [x for x in xs if p(x)]
        elif t.kind == TermKind.COMP:
            f = eval_term(t.children[0], env)
            g = eval_term(t.children[1], env)
            return lambda x: f(g(x))
        elif t.kind == TermKind.FOLDR:
            c = eval_term(t.children[0], env)
            z = eval_term(t.children[1], env)
            xs = eval_term(t.children[2], env)
            result = z
            for x in reversed(xs):
                result = c(x, result)
            return result

    xs = var(0)
    f = var(1)
    g = var(2)
    p = var(3)

    test_cases = [
        {
            'name': 'map(double) ∘ map(inc)',
            'term': unstream(smap(f, stream(unstream(smap(g, stream(xs)))))),
            'env': {
                0: [1, 2, 3, 4, 5],
                1: lambda x: x * 2,
                2: lambda x: x + 1,
            }
        },
        {
            'name': 'filter(even) ∘ map(triple)',
            'term': unstream(sfilter(p, stream(unstream(smap(f, stream(xs)))))),
            'env': {
                0: [1, 2, 3, 4, 5],
                1: lambda x: x * 3,
                3: lambda x: x % 2 == 0,
            }
        },
    ]

    print()
    all_pass = True
    for tc in test_cases:
        term = tc['term']
        nf = complete_reduction(term)
        env = tc['env']

        v_orig = eval_term(term, env)
        v_fused = eval_term(nf, env)
        ok = v_orig == v_fused

        status = "✓ PASS" if ok else "✗ FAIL"
        print(f"  {tc['name']}: {status}")
        print(f"    Original result: {v_orig}")
        print(f"    Fused result:    {v_fused}")
        if not ok:
            all_pass = False

    print()
    if all_pass:
        print("  All verification checks passed!")
        print("  (Formally guaranteed by normalize_sound in Lean 4)")
    print()


if __name__ == '__main__':
    application_1_pipeline_optimization()
    application_2_cost_analysis()
    application_3_verification()


#!/usr/bin/env python3
"""
Certified Stream Fusion — Interactive Demo

Demonstrates the stream fusion rewrite system:
  1. Constructs representative producer/consumer pipelines
  2. Runs the normalization procedure (stream/unstream cancellation)
  3. Displays original term, normalized term, and admin-cost reduction
  4. Checks extensional agreement on finite test inputs
  5. Summarizes which benchmarks achieved full fusion
"""

from dataclasses import dataclass
from typing import Optional, Callable
from enum import Enum, auto


# ============================================================================
# Term Language
# ============================================================================

class TermKind(Enum):
    VAR = auto()
    STREAM = auto()
    UNSTREAM = auto()
    SMAP = auto()
    SFILTER = auto()
    COMP = auto()
    FOLDR = auto()


@dataclass
class Term:
    kind: TermKind
    children: list  # child Terms
    var_id: Optional[int] = None  # for VAR

    def __repr__(self):
        return pretty(self)


def var(n: int) -> Term:
    return Term(TermKind.VAR, [], var_id=n)

def stream(t: Term) -> Term:
    return Term(TermKind.STREAM, [t])

def unstream(t: Term) -> Term:
    return Term(TermKind.UNSTREAM, [t])

def smap(f: Term, t: Term) -> Term:
    return Term(TermKind.SMAP, [f, t])

def sfilter(p: Term, t: Term) -> Term:
    return Term(TermKind.SFILTER, [p, t])

def comp(f: Term, g: Term) -> Term:
    return Term(TermKind.COMP, [f, g])

def foldr(c: Term, z: Term, xs: Term) -> Term:
    return Term(TermKind.FOLDR, [c, z, xs])


# ============================================================================
# Pretty Printing
# ============================================================================

VAR_NAMES = {0: "xs", 1: "f", 2: "g", 3: "p", 4: "q", 5: "c", 6: "z",
             7: "h", 8: "k"}

def pretty(t: Term) -> str:
    if t.kind == TermKind.VAR:
        return VAR_NAMES.get(t.var_id, f"x{t.var_id}")
    elif t.kind == TermKind.STREAM:
        return f"stream({pretty(t.children[0])})"
    elif t.kind == TermKind.UNSTREAM:
        return f"unstream({pretty(t.children[0])})"
    elif t.kind == TermKind.SMAP:
        return f"smap({pretty(t.children[0])}, {pretty(t.children[1])})"
    elif t.kind == TermKind.SFILTER:
        return f"sfilter({pretty(t.children[0])}, {pretty(t.children[1])})"
    elif t.kind == TermKind.COMP:
        return f"comp({pretty(t.children[0])}, {pretty(t.children[1])})"
    elif t.kind == TermKind.FOLDR:
        return f"foldr({pretty(t.children[0])}, {pretty(t.children[1])}, {pretty(t.children[2])})"
    return "?"


# ============================================================================
# Administrative Complexity
# ============================================================================

def admin_count(t: Term) -> int:
    """Count stream/unstream nodes (administrative complexity)."""
    if t.kind == TermKind.VAR:
        return 0
    elif t.kind in (TermKind.STREAM, TermKind.UNSTREAM):
        return 1 + admin_count(t.children[0])
    elif t.kind in (TermKind.SMAP, TermKind.SFILTER, TermKind.COMP):
        return sum(admin_count(c) for c in t.children)
    elif t.kind == TermKind.FOLDR:
        return sum(admin_count(c) for c in t.children)
    return 0


def has_redex(t: Term) -> bool:
    """Check for stream(unstream(_)) redex at any depth."""
    if t.kind == TermKind.STREAM and t.children[0].kind == TermKind.UNSTREAM:
        return True
    if t.kind == TermKind.VAR:
        return False
    return any(has_redex(c) for c in t.children)


# ============================================================================
# Fusion Normalization
# ============================================================================

def reduce_once(t: Term) -> Optional[Term]:
    """One step of stream/unstream cancellation, left-to-right."""
    if t.kind == TermKind.STREAM and t.children[0].kind == TermKind.UNSTREAM:
        return t.children[0].children[0]

    if t.kind == TermKind.VAR:
        return None

    if t.kind == TermKind.STREAM:
        inner = reduce_once(t.children[0])
        return Term(TermKind.STREAM, [inner]) if inner else None

    if t.kind == TermKind.UNSTREAM:
        inner = reduce_once(t.children[0])
        return Term(TermKind.UNSTREAM, [inner]) if inner else None

    # Binary constructors: try left, then right
    if t.kind in (TermKind.SMAP, TermKind.SFILTER, TermKind.COMP):
        left = reduce_once(t.children[0])
        if left:
            return Term(t.kind, [left, t.children[1]])
        right = reduce_once(t.children[1])
        if right:
            return Term(t.kind, [t.children[0], right])
        return None

    if t.kind == TermKind.FOLDR:
        for i in range(3):
            r = reduce_once(t.children[i])
            if r:
                new_children = list(t.children)
                new_children[i] = r
                return Term(t.kind, new_children)
        return None

    return None


def normalize(t: Term) -> tuple[Term, int]:
    """Normalize by iterating fusion steps. Returns (normal_form, step_count)."""
    steps = 0
    current = t
    while True:
        result = reduce_once(current)
        if result is None:
            break
        current = result
        steps += 1
    return current, steps


def complete_reduction(t: Term) -> Term:
    """Complete reduction: contract ALL stream/unstream pairs simultaneously."""
    if t.kind == TermKind.STREAM:
        inner = complete_reduction(t.children[0])
        if inner.kind == TermKind.UNSTREAM:
            return inner.children[0]
        return Term(TermKind.STREAM, [inner])

    if t.kind == TermKind.UNSTREAM:
        return Term(TermKind.UNSTREAM, [complete_reduction(t.children[0])])

    if t.kind == TermKind.VAR:
        return t

    new_children = [complete_reduction(c) for c in t.children]
    return Term(t.kind, new_children)


# ============================================================================
# Semantic Evaluation (for extensional checking)
# ============================================================================

def evaluate(t: Term, env: dict[int, any], model: dict) -> any:
    """Evaluate a term in a concrete model."""
    if t.kind == TermKind.VAR:
        return env[t.var_id]
    elif t.kind == TermKind.STREAM:
        return model['stream'](evaluate(t.children[0], env, model))
    elif t.kind == TermKind.UNSTREAM:
        return model['unstream'](evaluate(t.children[0], env, model))
    elif t.kind == TermKind.SMAP:
        f_val = evaluate(t.children[0], env, model)
        t_val = evaluate(t.children[1], env, model)
        return model['smap'](f_val, t_val)
    elif t.kind == TermKind.SFILTER:
        p_val = evaluate(t.children[0], env, model)
        t_val = evaluate(t.children[1], env, model)
        return model['sfilter'](p_val, t_val)
    elif t.kind == TermKind.COMP:
        f_val = evaluate(t.children[0], env, model)
        g_val = evaluate(t.children[1], env, model)
        return model['comp'](f_val, g_val)
    elif t.kind == TermKind.FOLDR:
        c_val = evaluate(t.children[0], env, model)
        z_val = evaluate(t.children[1], env, model)
        xs_val = evaluate(t.children[2], env, model)
        return model['foldr'](c_val, z_val, xs_val)


def list_model():
    """A concrete model where stream/unstream are identity on lists."""
    return {
        'stream': lambda x: x,  # identity (stream ∘ unstream = id)
        'unstream': lambda x: x,
        'smap': lambda f, xs: [f(x) for x in xs],
        'sfilter': lambda p, xs: [x for x in xs if p(x)],
        'comp': lambda f, g: lambda x: f(g(x)),
        'foldr': lambda c, z, xs: _foldr(c, z, xs),
    }


def _foldr(c, z, xs):
    result = z
    for x in reversed(xs):
        result = c(x, result)
    return result


# ============================================================================
# Benchmark Examples
# ============================================================================

def build_benchmarks():
    """Construct representative producer/consumer pipelines."""
    xs = var(0)  # input list
    f = var(1)   # function f
    g = var(2)   # function g
    p = var(3)   # predicate p
    c = var(5)   # combiner
    z = var(6)   # zero

    benchmarks = []

    # 1. stream ∘ unstream (direct cancellation)
    benchmarks.append({
        'name': 'stream ∘ unstream',
        'term': stream(unstream(xs)),
        'expected_fused': xs,
    })

    # 2. map f (map g xs) — after stream decomposition
    # = unstream(smap f (stream(unstream(smap g (stream xs)))))
    t2 = unstream(smap(f, stream(unstream(smap(g, stream(xs))))))
    benchmarks.append({
        'name': 'map f ∘ map g (decomposed)',
        'term': t2,
    })

    # 3. filter p (map f xs) — after stream decomposition
    t3 = unstream(sfilter(p, stream(unstream(smap(f, stream(xs))))))
    benchmarks.append({
        'name': 'filter p ∘ map f (decomposed)',
        'term': t3,
    })

    # 4. foldr c z (map f xs) — after stream decomposition
    t4 = foldr(c, z, unstream(smap(f, stream(xs))))
    benchmarks.append({
        'name': 'foldr c z ∘ map f',
        'term': t4,
    })

    # 5. Nested: map f ∘ map g ∘ filter p (decomposed)
    t5 = unstream(smap(f, stream(unstream(smap(g, stream(
         unstream(sfilter(p, stream(xs)))))))))
    benchmarks.append({
        'name': 'map f ∘ map g ∘ filter p (decomposed)',
        'term': t5,
    })

    # 6. Double stream/unstream wrapping
    t6 = stream(unstream(stream(unstream(xs))))
    benchmarks.append({
        'name': 'stream ∘ unstream ∘ stream ∘ unstream',
        'term': t6,
    })

    # 7. map f ∘ filter p ∘ map g ∘ filter q
    q = var(4)
    inner = unstream(sfilter(q, stream(xs)))
    inner2 = unstream(smap(g, stream(inner)))
    inner3 = unstream(sfilter(p, stream(inner2)))
    t7 = unstream(smap(f, stream(inner3)))
    benchmarks.append({
        'name': 'map f ∘ filter p ∘ map g ∘ filter q',
        'term': t7,
    })

    return benchmarks


# ============================================================================
# Main Demo
# ============================================================================

def main():
    print("=" * 72)
    print("  CERTIFIED STREAM FUSION — Demo")
    print("  Compiler optimization as higher-order equational completion")
    print("=" * 72)
    print()

    benchmarks = build_benchmarks()
    model = list_model()

    results = []
    for i, bm in enumerate(benchmarks):
        t = bm['term']
        nf, steps = normalize(t)
        cr = complete_reduction(t)
        orig_admin = admin_count(t)
        fused_admin = admin_count(nf)
        is_fused = not has_redex(nf)
        reduction = orig_admin - fused_admin

        print(f"Benchmark {i+1}: {bm['name']}")
        print(f"  Original:    {pretty(t)}")
        print(f"  Normalized:  {pretty(nf)}")
        print(f"  Admin cost:  {orig_admin} → {fused_admin} (reduced by {reduction})")
        print(f"  Steps:       {steps}")
        print(f"  Fully fused: {'✓' if is_fused else '✗'}")

        # Complete reduction check (should agree with normalize)
        cr_agrees = pretty(cr) == pretty(nf)
        print(f"  CR agrees:   {'✓' if cr_agrees else '✗'}")

        # Extensional check on sample inputs
        env_concrete = {
            0: [1, 2, 3, 4, 5],
            1: lambda x: x * 2,
            2: lambda x: x + 1,
            3: lambda x: x % 2 == 0,
            4: lambda x: x > 2,
            5: lambda x, acc: x + acc,
            6: 0,
            7: lambda x: x * 3,
            8: lambda x: x - 1,
        }
        try:
            v_orig = evaluate(t, env_concrete, model)
            v_fused = evaluate(nf, env_concrete, model)
            ext_ok = v_orig == v_fused
            print(f"  Ext. check:  {'✓' if ext_ok else '✗'} (orig={v_orig}, fused={v_fused})")
        except Exception as e:
            ext_ok = None
            print(f"  Ext. check:  skipped ({e})")

        results.append({
            'name': bm['name'],
            'fused': is_fused,
            'reduction': reduction,
            'steps': steps,
            'ext_ok': ext_ok,
        })
        print()

    # Summary
    print("=" * 72)
    print("  SUMMARY")
    print("=" * 72)
    total = len(results)
    fully_fused = sum(1 for r in results if r['fused'])
    ext_passed = sum(1 for r in results if r['ext_ok'] is True)
    total_reduction = sum(r['reduction'] for r in results)

    print(f"  Benchmarks:       {total}")
    print(f"  Fully fused:      {fully_fused}/{total}")
    print(f"  Ext. checks OK:   {ext_passed}/{total}")
    print(f"  Total admin cost reduction: {total_reduction}")
    print()
    print("  Key theorem (proved in Lean 4):")
    print("    fused_normal_form_unique: fused normal forms are UNIQUE")
    print("    fusion_step_admin_decrease: each step reduces cost by ≥ 2")
    print("    normalize_sound: normalization preserves semantics")
    print()


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Stream Fusion Cost Reduction

Visualizes how administrative complexity decreases during fusion normalization
for pipelines of increasing depth. Produces a plot showing:
1. Admin cost before/after fusion vs pipeline depth
2. Number of fusion steps vs pipeline depth
3. Cost savings (admin nodes eliminated)
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from enum import Enum, auto
from dataclasses import dataclass, field
from typing import Optional, List


# Inline all needed types and functions
class TermKind(Enum):
    VAR = auto()
    STREAM = auto()
    UNSTREAM = auto()
    SMAP = auto()
    SFILTER = auto()
    COMP = auto()
    FOLDR = auto()

@dataclass
class Term:
    kind: TermKind
    children: list = field(default_factory=list)
    var_id: Optional[int] = None

def var(n): return Term(TermKind.VAR, var_id=n)
def stream(t): return Term(TermKind.STREAM, [t])
def unstream(t): return Term(TermKind.UNSTREAM, [t])
def smap(f, t): return Term(TermKind.SMAP, [f, t])

def admin_count(t):
    if t.kind == TermKind.VAR: return 0
    if t.kind in (TermKind.STREAM, TermKind.UNSTREAM):
        return 1 + admin_count(t.children[0])
    return sum(admin_count(c) for c in t.children)

def has_redex(t):
    if t.kind == TermKind.STREAM and t.children[0].kind == TermKind.UNSTREAM:
        return True
    if t.kind == TermKind.VAR: return False
    return any(has_redex(c) for c in t.children)

def reduce_once(t):
    if t.kind == TermKind.STREAM and t.children[0].kind == TermKind.UNSTREAM:
        return t.children[0].children[0]
    if t.kind == TermKind.VAR: return None
    if t.kind == TermKind.STREAM:
        r = reduce_once(t.children[0])
        return Term(TermKind.STREAM, [r]) if r else None
    if t.kind == TermKind.UNSTREAM:
        r = reduce_once(t.children[0])
        return Term(TermKind.UNSTREAM, [r]) if r else None
    for i, child in enumerate(t.children):
        r = reduce_once(child)
        if r is not None:
            nc = list(t.children); nc[i] = r
            return Term(t.kind, nc)
    return None

def normalize(t):
    steps = 0; current = t
    while True:
        result = reduce_once(current)
        if result is None: break
        current = result; steps += 1
    return current, steps


# Generate data
depths = list(range(1, 16))
admin_before = []
admin_after = []
step_counts = []

xs = var(0)
f = var(1)

for d in depths:
    term = xs
    for _ in range(d):
        term = unstream(smap(f, stream(term)))
    nf, steps = normalize(term)
    admin_before.append(admin_count(term))
    admin_after.append(admin_count(nf))
    step_counts.append(steps)

savings = [b - a for b, a in zip(admin_before, admin_after)]

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Admin cost before/after
ax1 = axes[0]
ax1.plot(depths, admin_before, 'o-', color='#e74c3c', linewidth=2,
         markersize=6, label='Before fusion')
ax1.plot(depths, admin_after, 's-', color='#27ae60', linewidth=2,
         markersize=6, label='After fusion')
ax1.fill_between(depths, admin_after, admin_before, alpha=0.15, color='#27ae60')
ax1.set_xlabel('Pipeline Depth', fontsize=12)
ax1.set_ylabel('Administrative Nodes', fontsize=12)
ax1.set_title('Admin Cost: Before vs After Fusion', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Steps required
ax2 = axes[1]
ax2.bar(depths, step_counts, color='#3498db', alpha=0.8, edgecolor='#2c3e50')
ax2.set_xlabel('Pipeline Depth', fontsize=12)
ax2.set_ylabel('Fusion Steps', fontsize=12)
ax2.set_title('Steps to Normalize', fontsize=13)
ax2.grid(True, alpha=0.3, axis='y')

# Plot 3: Cost savings
ax3 = axes[2]
ax3.plot(depths, savings, 'D-', color='#9b59b6', linewidth=2, markersize=6)
ax3.fill_between(depths, savings, alpha=0.2, color='#9b59b6')
ax3.set_xlabel('Pipeline Depth', fontsize=12)
ax3.set_ylabel('Nodes Eliminated', fontsize=12)
ax3.set_title('Administrative Cost Savings', fontsize=13)
ax3.grid(True, alpha=0.3)

# Add theorem annotation
ax3.annotate('Theorem: each step\nsaves ≥ 2 nodes',
            xy=(8, savings[7]), xytext=(10, savings[3]),
            arrowprops=dict(arrowstyle='->', color='#8e44ad'),
            fontsize=10, color='#8e44ad',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#f0e6ff'))

plt.suptitle('Certified Stream Fusion: Cost Analysis',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('fusion_cost_analysis.png', dpi=150, bbox_inches='tight')
print("Saved fusion_cost_analysis.png")
