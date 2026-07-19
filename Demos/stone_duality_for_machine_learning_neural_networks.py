from pathlib import Path
import json

article=Path('ARTICLE.md').read_text()
paper=Path('RESEARCH_PAPER.md').read_text()
tex=Path('RESEARCH_PAPER.tex').read_text()
demo=Path('demo.py').read_text()

common_py='''from __future__ import annotations\nfrom itertools import combinations, product\nfrom typing import Callable, Iterable, TypeVar\nX = TypeVar("X")\nPattern = tuple[int, ...]\n\ndef feasible_patterns(domain: Iterable[X], activation: Callable[[X], Pattern]) -> set[Pattern]:\n    return {activation(x) for x in domain}\n'''

demos=[
 {"name":"Feasible Patterns in a Nested Two-Threshold System","description":"Enumerates the formal and feasible activation patterns for two nested threshold gates on a finite one-dimensional sample. It identifies the impossible pattern, checks the sharp cardinality bound, and reports the utilization ratio of the Boolean cube.","code":common_py+'''\ndef main() -> None:\n    domain = range(-5, 7)\n    activation = lambda x: (int(x > 0), int(x > 2))\n    feasible = feasible_patterns(domain, activation)\n    formal = set(product((0, 1), repeat=2))\n    print("feasible:", sorted(feasible))\n    print("infeasible:", sorted(formal-feasible))\n    print("bound:", len(feasible), "<=", len(formal))\n    assert feasible == {(0,0),(1,0),(1,1)}\nif __name__ == "__main__": main()\n'''},
 {"name":"Exact Descent of an Activation-Invariant Classifier","description":"Builds the unique lookup table on feasible activation patterns through which an activation-invariant classifier factors. It verifies reconstruction on every sampled input and demonstrates that inconsistent labels on one activation fibre are rejected.","code":common_py+'''\nfrom typing import Hashable, TypeVar\nY = TypeVar("Y", bound=Hashable)\ndef descend(domain: Iterable[X], activation: Callable[[X], Pattern], classifier: Callable[[X], Y]) -> dict[Pattern,Y]:\n    result: dict[Pattern,Y] = {}\n    for x in domain:\n        p, y = activation(x), classifier(x)\n        if p in result and result[p] != y: raise ValueError("not activation-invariant")\n        result[p] = y\n    return result\ndef main() -> None:\n    domain=list(range(-4,6)); activation=lambda x:(int(x>0),int(x>2))\n    classifier=lambda x:int(activation(x)!=(0,0))\n    table=descend(domain,activation,classifier)\n    assert all(table[activation(x)]==classifier(x) for x in domain)\n    print(table)\nif __name__ == "__main__": main()\n'''},
 {"name":"Exhaustive VC Dimension of the Feasible Powerset","description":"Constructs every subset of a three-point feasible activation space and checks the shattering definition exhaustively. It confirms that the full powerset has VC dimension three while a family containing one fixed region has VC dimension zero.","code":'''from __future__ import annotations\nfrom itertools import combinations\nfrom typing import FrozenSet, Iterable, TypeVar\nX=TypeVar("X")\ndef powerset(xs: Iterable[X]) -> list[FrozenSet[X]]:\n    a=list(xs); return [frozenset(c) for r in range(len(a)+1) for c in combinations(a,r)]\ndef shatters(C: list[FrozenSet[X]], S: FrozenSet[X]) -> bool:\n    traces={c&S for c in C}; return all(t in traces for t in powerset(S))\ndef vc(U: list[X], C: list[FrozenSet[X]]) -> int:\n    return max(len(s) for s in powerset(U) if shatters(C,s))\ndef main() -> None:\n    F=[(0,0),(1,0),(1,1)]; full=powerset(F)\n    print("full powerset VC dimension:",vc(F,full))\n    print("one fixed concept VC dimension:",vc(F,[frozenset({(1,0)})]))\n    assert vc(F,full)==3 and vc(F,[frozenset({(1,0)})])==0\nif __name__ == "__main__": main()\n'''}]

algorithms=[
 {"name":"Finite-Domain Feasible Activation Enumeration","description":"Computes the exact range of a k-bit activation map over N explicitly listed inputs by inserting each observed pattern into a hash set. The expected running time is O(Nk), assuming pattern construction costs O(k) and hashed insertion is expected constant time after hashing; storage is O(rk) bits for r feasible patterns. The output is the finite semantic space and directly determines its atom count, full-powerset VC dimension, and number of invariant regions.","pseudocode":"INPUT: finite domain X and activation map a producing k-bit words\nF <- empty hash set\nFOR each x in X:\n    p <- a(x)\n    insert p into F\nRETURN F, |F|, 2^|F|","code":common_py+'''\ndef enumerate_semantics(domain: Iterable[X], activation: Callable[[X], Pattern]) -> tuple[set[Pattern], int, int]:\n    feasible=feasible_patterns(domain,activation)\n    return feasible,len(feasible),2**len(feasible)\n'''},
 {"name":"Invariant Classifier Quotient Construction","description":"Constructs the unique classifier on the feasible quotient while simultaneously testing activation invariance. A dictionary stores the first label seen for each pattern; a later conflicting label certifies that the classifier splits a fibre. Expected time is O(Nk), and storage is O(r(k+ell)) when labels require ell units of space.","pseudocode":"INPUT: finite domain X, activation a, classifier f\nD <- empty dictionary\nFOR each x in X:\n    p <- a(x); y <- f(x)\n    IF p is in D and D[p] != y: RETURN failure with conflicting fibre p\n    D[p] <- y\nRETURN D as the unique descended classifier","code":demos[1]['code']},
 {"name":"Exhaustive Finite VC-Dimension Certification","description":"Evaluates the shattering definition on every subset of a finite universe. For a universe of r points and c concepts, direct enumeration takes O(3^r c) set-membership work in a straightforward implementation, so it is intended for small semantic spaces. For the full powerset family the theorem gives the answer r immediately; exhaustive computation serves as a transparent numerical certificate and supports restricted-family experiments.","pseudocode":"INPUT: finite universe U and concept family C\nbest <- 0\nFOR each subset S of U:\n    traces <- {concept intersect S : concept in C}\n    IF every subset of S belongs to traces:\n        best <- max(best, |S|)\nRETURN best","code":demos[2]['code']}]

visualizations=[
 {"name":"Activation-Cube Feasibility Diagram","description":"Draws the four vertices of the two-gate Boolean cube, highlighting the three feasible nested-threshold patterns and marking the impossible pattern with a cross.","code":'''from __future__ import annotations\nimport matplotlib.pyplot as plt\ndef main() -> None:\n    feasible={(0,0),(1,0),(1,1)}\n    for x,y in [(0,0),(0,1),(1,0),(1,1)]:\n        ok=(x,y) in feasible\n        plt.scatter([x],[y],s=180,c="#20b486" if ok else "#d1495b",marker="o" if ok else "x")\n        plt.text(x+.04,y+.04,f"{x}{y}")\n    for a,b in [((0,0),(1,0)),((0,0),(0,1)),((1,0),(1,1)),((0,1),(1,1))]: plt.plot([a[0],b[0]],[a[1],b[1]],color="#b8c2cc",zorder=0)\n    plt.title("Feasible states in the two-gate cube"); plt.axis("off"); plt.savefig("activation_cube.png",dpi=180,bbox_inches="tight")\nif __name__=="__main__": main()\n'''},
 {"name":"Formal-versus-Feasible Capacity Comparison","description":"Plots formal cube size and feasible counts for independent, nested, and duplicate gate systems, making the effect of feasibility constraints and redundancy visually explicit.","code":'''from __future__ import annotations\nimport matplotlib.pyplot as plt\ndef main() -> None:\n    k=list(range(1,9)); formal=[2**n for n in k]; independent=formal; nested=[n+1 for n in k]; duplicate=[2]*8\n    plt.semilogy(k,formal,"k--",label="formal maximum")\n    plt.semilogy(k,independent,"o-",label="independent gates")\n    plt.semilogy(k,nested,"s-",label="nested thresholds")\n    plt.semilogy(k,duplicate,"^-",label="duplicate gates")\n    plt.xlabel("number of gates k"); plt.ylabel("pattern count"); plt.legend(); plt.tight_layout(); plt.savefig("capacity_comparison.png",dpi=180)\nif __name__=="__main__": main()\n'''},
 {"name":"Boolean Atoms and Their Unions","description":"Displays three feasible patterns as elementary atoms and all eight Boolean regions as binary selections of those atoms, illustrating why r atoms generate 2^r algebra elements.","code":'''from __future__ import annotations\nfrom itertools import product\nimport matplotlib.pyplot as plt\ndef main() -> None:\n    rows=list(product((0,1),repeat=3)); fig,ax=plt.subplots(figsize=(6,5))\n    ax.imshow(rows,cmap="YlGn",aspect="auto",vmin=0,vmax=1)\n    ax.set_xticks(range(3),["00","10","11"]); ax.set_yticks(range(8),[f"region {i}" for i in range(8)])\n    ax.set_xlabel("feasible-pattern atoms"); ax.set_title("All 2^3 unions of three atoms")\n    plt.tight_layout(); plt.savefig("atom_unions.png",dpi=180)\nif __name__=="__main__": main()\n'''}]

style='''body{font-family:system-ui,sans-serif;max-width:850px;margin:30px auto;padding:20px;background:#f7fafc;color:#172033}h1{color:#4934a5}.card{background:white;padding:18px;border-radius:14px;box-shadow:0 8px 30px #243b5320;margin:14px 0}button,input,select{padding:9px;margin:5px;border-radius:7px;border:1px solid #aab}.bit{display:inline-block;padding:10px;margin:4px;border-radius:8px;background:#e8e2ff}.yes{background:#b8f2d5}.no{background:#ffc8cf}'''
interactive=[
 {"title":"Explore Feasible States of Nested Threshold Gates","description":"An interactive threshold laboratory. Readers move two one-dimensional thresholds, sample the line, and see which of the four formal two-bit patterns are actually realized; the widget exposes the order constraint responsible for the missing pattern.","html":f'''<!DOCTYPE html><html><head><meta charset="utf-8"><title>Nested Threshold Explorer</title><style>{style}</style></head><body><h1>Nested Threshold Explorer</h1><div class="card"><label>First threshold <input id="a" type="range" min="-5" max="5" step="1" value="0"></label><label>Second threshold <input id="b" type="range" min="-5" max="5" step="1" value="2"></label><p id="rule"></p><div id="patterns"></div></div><script>function draw(){{let a=+document.querySelector('#a').value,b=+document.querySelector('#b').value,F=new Set();for(let x=-6;x<=6;x+=.1)F.add(`${{+(x>a)}}${{+(x>b)}}`);document.querySelector('#rule').textContent=`gates: x > ${{a}} and x > ${{b}}; feasible ${{F.size}} / 4`;document.querySelector('#patterns').innerHTML=['00','01','10','11'].map(p=>`<span class="bit ${{F.has(p)?'yes':'no'}}">${{p}} ${{F.has(p)?'feasible':'infeasible'}}</span>`).join('')}}document.querySelectorAll('input').forEach(x=>x.oninput=draw);draw()</script></body></html>'''},
 {"title":"Boolean Region Composer on Feasible Atoms","description":"Lets readers toggle feasible activation atoms to build a decision region. It updates the selected subset, its complement, and the count of all possible regions, turning Boolean algebra operations into a direct visual experience.","html":f'''<!DOCTYPE html><html><head><meta charset="utf-8"><title>Region Composer</title><style>{style}</style></head><body><h1>Boolean Region Composer</h1><div class="card"><p>Click atoms to include or exclude them from the positive region.</p><div id="atoms"></div><p id="result"></p></div><script>let A=['00','10','11'],on=new Set();function draw(){{document.querySelector('#atoms').innerHTML=A.map(p=>`<button class="${{on.has(p)?'yes':''}}" onclick="toggle('${{p}}')">atom ${{p}}</button>`).join('');let comp=A.filter(p=>!on.has(p));document.querySelector('#result').innerHTML=`Selected region: [${{[...on].join(', ')}}]<br>Complement: [${{comp.join(', ')}}]<br>Three atoms generate 2<sup>3</sup> = 8 regions.`}}function toggle(p){{on.has(p)?on.delete(p):on.add(p);draw()}}draw()</script></body></html>'''},
 {"title":"VC Shattering Laboratory","description":"Allows readers to choose a sample of feasible points and compare the traces supplied by the full powerset against those supplied by one fixed concept. It reports whether the chosen sample is shattered and explains the exact VC-dimension contrast.","html":f'''<!DOCTYPE html><html><head><meta charset="utf-8"><title>Shattering Laboratory</title><style>{style}</style></head><body><h1>VC Shattering Laboratory</h1><div class="card"><label>Concept family <select id="family"><option value="full">all subsets</option><option value="one">one fixed concept {{10}}</option></select></label><p>Sample:</p><div id="points"></div><button onclick="check()">Check shattering</button><p id="answer"></p></div><script>let P=['00','10','11'],S=new Set(P);document.querySelector('#points').innerHTML=P.map(p=>`<label class="bit"><input type="checkbox" checked onchange="this.checked?S.add('${{p}}'):S.delete('${{p}}')">${{p}}</label>`).join('');function check(){{let full=document.querySelector('#family').value==='full',ok=full||S.size===0;document.querySelector('#answer').innerHTML=ok?`<b>Shattered.</b> Every one of the ${{2**S.size}} traces is available.`:`<b>Not shattered.</b> One fixed concept supplies only one trace, but a nonempty sample requires at least two.`}}check()</script></body></html>'''}]

future='''# Future directions\n\n## What is now established\n\nFor an arbitrary activation map `a : X → (Fin k → Bool)`, the correct finite semantic space is its range `Feasible a`. The development establishes:\n\n1. The feasible space has at most `2^k` points.\n2. It has exactly `2^k` points if and only if every formal activation pattern is feasible.\n3. Every classifier constant on activation fibres factors uniquely through the feasible space.\n4. Pullback embeds the Boolean algebra of subsets of the feasible space into input-space regions, preserving complement and intersection.\n5. Its image consists exactly of activation-invariant regions.\n6. Atoms of this region algebra are singleton feasible patterns, so their count is the number of feasible patterns and is at most `2^k`.\n7. The full powerset concept family has VC dimension equal to the number of feasible patterns.\n8. A single fixed decision region cannot shatter a nonempty set.\n\nThis gives a precise finite Stone-style syntax/semantics theorem while separating it from claims that do not hold without added assumptions.\n\n## Corrections to the motivating conjecture\n\n* A `k`-neuron network need not realize all `2^k` activation patterns. Correlated, redundant, or geometrically infeasible signs reduce the range.\n* Deep-network neuron preactivations are generally piecewise affine in the original input, not globally defined by only `w₁ + ⋯ + w_L` input hyperplanes.\n* A fixed classifier is not a hypothesis class with VC dimension. VC dimension must be assigned to a parameterized family. The equality established here is for the full Boolean algebra of all subsets of the finite feasible space.\n* The number of atoms equals the number of feasible patterns. The number of elements of the powerset Boolean algebra is instead `2^(number of feasible patterns)`.\n* Linear regions may refine, coarsen, or otherwise differ from activation patterns in degenerate networks. Their equality requires explicit nondegeneracy assumptions.\n\n## Next targets\n\n1. Equip the feasible space with its finite discrete topology and prove directly that every subset is clopen, then package realization as a Boolean-algebra embedding into the input powerset.\n2. Define sign activations of affine hyperplane arrangements over `ℝ^n`; prove feasibility is equivalent to nonemptiness of the corresponding system of strict and weak linear inequalities.\n3. Develop a one-hidden-layer ReLU network and show its output is affine on each feasible activation cell.\n4. State sufficient genericity conditions under which feasible activation patterns correspond to nonempty linear regions.\n5. Define parameterized families of output labelings on a fixed activation complex. Prove VC upper bounds from the number of feasible atoms, and identify hypotheses under which the full bound is attained.\n6. Replace the finite powerset presentation by the Stone spectrum of a finite Boolean algebra and construct the explicit homeomorphism between ultrafilters and atoms.\n7. Investigate the hyperplane-arrangement bound `∑_{i=0}^n choose(k,i)` for feasible patterns of `k` affine gates in dimension `n`, including the assumptions needed for equality.'''

layout='''# Neural Activations as a Finite Stone Space\n\nA network may expose $k$ binary gates, yet geometry decides which of the $2^k$ formal bit strings can occur. Begin by experimenting with two threshold gates.\n\n{{interactive_demo:0}}\n\nThe realized strings form the **feasible activation space**. The enumeration routine computes this range on a finite domain and reports its semantic capacity.\n\n{{algorithm:0}}\n\n{{demo:0}}\n\n## From feasible points to Boolean regions\n\nEvery feasible pattern is an atom. Any activation-invariant decision region is a unique union of these atoms, so $r$ feasible points generate $2^r$ regions.\n\n{{interactive_demo:1}}\n\n{{visualization:2}}\n\n<details><summary>Reveal the representation theorem</summary>For an activation map $a:X\to\{0,1\}^k$, let $F=a(X)$. Pullback sends $U\subseteq F$ to $a^{-1}(U)$. Preimages preserve complements and intersections. Surjectivity onto $F$ makes pullback injective. A region is in its image exactly when membership is constant whenever two inputs share an activation pattern.</details>\n\n## Lossless classifier compression\n\nIf equal patterns always receive equal labels, the classifier can be stored as one label per feasible pattern.\n\n{{algorithm:1}}\n\n{{demo:1}}\n\n<details><summary>Reveal the uniqueness argument</summary>For each feasible pattern, choose any input realizing it and assign that input's label. Fibre invariance makes the choice irrelevant. Any other factorization must agree because every feasible pattern has a witness.</details>\n\n## Capacity and shattering\n\nThe full family of all pattern subsets shatters the entire feasible space. Its VC dimension is therefore $r$, the number of feasible points. A single fixed region cannot shatter a nonempty sample.\n\n{{interactive_demo:2}}\n\n{{algorithm:2}}\n\n{{demo:2}}\n\n<details><summary>Reveal the exact VC proof</summary>The powerset realizes every trace on every subset, so it shatters all $r$ feasible points. No sample in an $r$-point universe can be larger. Conversely, one fixed concept has only one trace, while a nonempty sample requires at least the empty trace and a singleton trace.</details>\n\n## Geometry controls feasibility\n\nIndependent signs can realize the full cube, nested thresholds produce only $k+1$ patterns, and duplicate gates may produce only two.\n\n{{visualization:0}}\n\n{{visualization:1}}\n\nFor background, see [Stone duality](https://en.wikipedia.org/wiki/Stone%27s_representation_theorem_for_Boolean_algebras), [VC dimension](https://en.wikipedia.org/wiki/Vapnik%E2%80%93Chervonenkis_dimension), and [hyperplane arrangements](https://en.wikipedia.org/wiki/Arrangement_of_hyperplanes). The central discipline is to distinguish formal patterns from feasible patterns, atoms from all Boolean elements, and a hypothesis family from one fixed classifier.'''

pkg={"title":"Finite Stone Semantics for Neural Activation Patterns","domain":"Novelty","description":"Neural activation patterns form a finite Stone-style semantic space whose Boolean subsets represent exactly the activation-invariant decision regions. Its feasible points, Boolean atoms, and full-powerset VC dimension coincide in number and are bounded sharply by 2^k for k gates.","authors":["Aristotle"],"date":"2026-07-19","key_results":["A k-gate activation map has at most 2^k feasible patterns, with equality exactly when every formal pattern is realizable.","Every activation-invariant classifier factors uniquely through the finite feasible activation space.","Boolean pullback represents exactly the activation-invariant input regions and preserves complements and intersections.","The atoms are singleton feasible patterns, and the full powerset concept family has VC dimension equal to their number.","A single fixed decision region cannot shatter any nonempty set."],"keywords":["Stone duality","neural networks","activation patterns","Boolean algebra","VC dimension","ReLU","feasible regions"],"article":article,"research_paper":paper,"research_paper_tex":tex,"demo":demo,"demos":demos,"algorithms":algorithms,"visualizations":visualizations,"interactive_demos":interactive,"interactive_layout":layout,"lean_proofs":"No formal-proof source is included in this publication-only package.","future_directions":future,"modules":{"demo":demo},"lean_files":[]}
Path('PACKAGE.json').write_text(json.dumps(pkg,indent=2,ensure_ascii=False)+'\n')


#!/usr/bin/env python3
"""Numerical demonstrations of finite Stone semantics for binary activations.

The script uses only the Python standard library. It enumerates feasible patterns,
checks the sharp 2^k bound, descends an invariant classifier, verifies Boolean
pullback identities, identifies atoms, and exhaustively confirms the shattering
claims on a small example.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Callable, Dict, FrozenSet, Hashable, Iterable, List, Sequence, Set, Tuple, TypeVar

X = TypeVar("X")
Y = TypeVar("Y", bound=Hashable)
Pattern = Tuple[int, ...]


def powerset(items: Iterable[X]) -> List[FrozenSet[X]]:
    """Return every subset of a finite iterable as a list of frozensets."""
    values = list(items)
    return [frozenset(c) for r in range(len(values) + 1) for c in combinations(values, r)]


def feasible_patterns(domain: Iterable[X], activation: Callable[[X], Pattern]) -> Set[Pattern]:
    """Enumerate the range of an activation map on a finite domain."""
    return {activation(x) for x in domain}


def descend_classifier(
    domain: Iterable[X], activation: Callable[[X], Pattern], classifier: Callable[[X], Y]
) -> Dict[Pattern, Y]:
    """Construct the unique descended classifier, rejecting fibre inconsistency."""
    descended: Dict[Pattern, Y] = {}
    for x in domain:
        pattern, label = activation(x), classifier(x)
        if pattern in descended and descended[pattern] != label:
            raise ValueError(f"classifier is not activation-invariant on pattern {pattern}")
        descended[pattern] = label
    return descended


def realize_region(
    domain: Iterable[X], activation: Callable[[X], Pattern], region: Set[Pattern]
) -> Set[X]:
    """Pull a subset of feasible patterns back to the input domain."""
    return {x for x in domain if activation(x) in region}


def shatters(concepts: Iterable[FrozenSet[X]], sample: FrozenSet[X]) -> bool:
    """Test the definition of shattering by comparing every possible trace."""
    traces = {frozenset(c.intersection(sample)) for c in concepts}
    return all(target in traces for target in powerset(sample))


def vc_dimension(universe: Sequence[X], concepts: Iterable[FrozenSet[X]]) -> int:
    """Compute VC dimension by exhaustive search on a finite universe."""
    concept_list = list(concepts)
    return max((len(s) for s in powerset(universe) if shatters(concept_list, s)), default=0)


def nested_threshold_demo() -> None:
    """Run a two-gate example with one infeasible formal pattern."""
    domain = list(range(-2, 4))

    def activation(x: int) -> Pattern:
        return (int(x > 0), int(x > 1))

    def classifier(x: int) -> int:
        # This label depends only on the activation pattern.
        return int(activation(x) in {(1, 0), (1, 1)})

    feasible = feasible_patterns(domain, activation)
    k = 2
    formal = set(product((0, 1), repeat=k))
    descended = descend_classifier(domain, activation, classifier)

    print("=== Nested-threshold activation system ===")
    print(f"sample domain: {domain}")
    print(f"formal patterns ({2**k}): {sorted(formal)}")
    print(f"feasible patterns ({len(feasible)}): {sorted(feasible)}")
    print(f"infeasible patterns: {sorted(formal - feasible)}")
    print(f"sharp bound: {len(feasible)} <= 2^{k} = {2**k}")
    print(f"surjective onto the formal cube: {feasible == formal}")
    print(f"descended classifier: {dict(sorted(descended.items()))}")
    assert all(descended[activation(x)] == classifier(x) for x in domain)

    feasible_list = sorted(feasible)
    algebra = powerset(feasible_list)
    atoms = [u for u in algebra if len(u) == 1]
    print(f"Boolean-algebra elements: {len(algebra)} = 2^{len(feasible)}")
    print(f"atoms: {len(atoms)} = number of feasible patterns")

    u = {(0, 0), (1, 0)}
    v = {(1, 0), (1, 1)}
    whole = set(domain)
    assert realize_region(domain, activation, feasible - u) == whole - realize_region(domain, activation, u)
    assert realize_region(domain, activation, u & v) == (
        realize_region(domain, activation, u) & realize_region(domain, activation, v)
    )
    print("pullback preserves complement and intersection: verified")

    concepts = [frozenset(u) for u in algebra]
    full_vc = vc_dimension(feasible_list, concepts)
    singleton_vc = vc_dimension(feasible_list, [frozenset({(1, 0)})])
    print(f"VC dimension of the full powerset family: {full_vc}")
    print(f"VC dimension of one fixed concept: {singleton_vc}")
    assert full_vc == len(feasible)
    assert singleton_vc == 0


def independent_gate_demo(k: int = 3) -> None:
    """Demonstrate equality in the pattern bound using independent coordinate signs."""
    domain = list(product((-1, 1), repeat=k))

    def activation(x: Tuple[int, ...]) -> Pattern:
        return tuple(int(value > 0) for value in x)

    feasible = feasible_patterns(domain, activation)
    print("\n=== Independent-coordinate gates ===")
    print(f"gates: {k}; feasible patterns: {len(feasible)}; formal maximum: {2**k}")
    print(f"every formal pattern feasible: {len(feasible) == 2**k}")
    assert len(feasible) == 2**k


def duplicate_gate_demo(k: int = 5) -> None:
    """Demonstrate severe pattern collapse caused by redundant gates."""
    domain = list(range(-3, 4))

    def activation(x: int) -> Pattern:
        bit = int(x > 0)
        return (bit,) * k

    feasible = feasible_patterns(domain, activation)
    print("\n=== Duplicate gates ===")
    print(f"gates: {k}; feasible patterns: {len(feasible)}; formal maximum: {2**k}")
    print(f"utilization ratio: {len(feasible) / 2**k:.4f}")
    assert feasible == {(0,) * k, (1,) * k}


def main() -> None:
    nested_threshold_demo()
    independent_gate_demo()
    duplicate_gate_demo()
    print("\nAll finite Stone-semantics demonstrations passed.")


if __name__ == "__main__":
    main()
