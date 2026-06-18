# The Logic of Dreams: Where Contradictions Coexist

*How mathematicians are building frameworks for reasoning in impossible worlds*

---

You're in a dream. You're at your childhood home, but it's also your office. Your mother is there, but she's also your boss. The cat that died three years ago purrs in your lap. None of this troubles you — in the dream, contradictions simply coexist.

For centuries, Western logic has been built on a bedrock principle: contradictions destroy everything. If you accept both "it is raining" and "it is not raining," then logic allows you to derive *any* conclusion whatsoever — that the moon is made of cheese, that 2 + 2 = 5, that you are Napoleon. Logicians call this principle *ex falso quodlibet* (from falsehood, anything follows), and it has been treated as an immutable law of thought since Aristotle.

But what if it's wrong? Or rather — what if there are legitimate forms of reasoning where this principle doesn't hold?

## The Problem with Explosion

The technical name for the catastrophe that follows from a single contradiction is *explosion*. It's actually quite easy to prove in classical logic: assume both P and not-P. From P, we get "P or Q" (since if P is true, then "P or anything" is true). But not-P eliminates the first option, leaving us with Q — and Q can be literally anything.

This argument is logically impeccable within its framework, but it has a disturbing consequence. Any system of beliefs that contains even one contradiction immediately becomes trivial — it proves everything, and therefore nothing meaningful.

Real-world reasoning doesn't work this way. Scientists regularly work with theories that have known contradictions (quantum mechanics and general relativity, for instance) without concluding that the moon is made of cheese. Legal systems operate with contradictory precedents. Medical databases contain conflicting diagnoses. And dreams — those nightly excursions into impossibility — demonstrate that our minds can navigate contradictions with remarkable fluidity.

## Four Shades of Truth

In the 1970s, the American logician Nuel Belnap proposed a radical solution: what if truth isn't binary? Instead of just "true" and "false," Belnap introduced four truth values:

- **True** (we have evidence for it)
- **False** (we have evidence against it)
- **Both** (we have evidence for AND against it)
- **Neither** (we have no evidence either way)

The crucial innovation is the "both" value. When a database tells you that a patient both has and doesn't have a particular condition, classical logic collapses. Belnap's system shrugs and says: "Fine, that's contradictory. Let's keep working." The contradiction is *contained* — it infects only the propositions directly involved, not the entire system.

This is exactly what happens in dreams. When you dream that your house is simultaneously in New York and London, the contradiction doesn't cascade into absurdity. You don't dream that therefore mathematics is wrong or that gravity has reversed. The impossibility stays local, and the rest of the dream proceeds with its own weird internal logic.

## When Learning Means Forgetting

But Belnap's logic reveals something even more surprising when combined with a second phenomenon: *non-monotone reasoning*.

In ordinary logic, learning more can never hurt. If you know enough to conclude X, then learning additional facts still lets you conclude X. This property — called *monotonicity* — seems obviously correct. But consider this scenario:

You know that birds fly. Tweety is a bird. Therefore, Tweety flies.

Now you learn that Tweety is a penguin. Suddenly, your conclusion is retracted. You no longer believe Tweety flies — not because you forgot that birds fly, but because the new information *conflicts* with the specific application of that rule.

This is non-monotone reasoning, and it's fundamental to how we actually think. Adding information can *remove* conclusions, not just add them. In formal terms: if Γ is a set of premises and Γ ⊢ p (p follows from Γ), then enlarging Γ to include conflicting information can make p no longer follow.

Recent mathematical work has formalized this precisely. A "skeptical consequence relation" declares that a conclusion follows from a set of premises only if nothing in the premises conflicts with it. The moment you add a conflicting fact, the conclusion is retracted — belief revision made mathematically rigorous.

## The Geometry of Impossible Worlds

Perhaps the most unexpected development is a connection to topology — the mathematical study of shapes and spaces.

In topology, an "open set" is a collection of points with a particular coherence property: you can freely combine (take unions of) open sets and always get another open set. This union axiom is so fundamental that it's part of the definition of a topological space.

But what happens when you weaken this axiom? You get what mathematicians now call a *quasi-topological space*: a structure where finite intersections are well-behaved, but arbitrary unions can fail. And here's the punchline — these quasi-topological spaces arise naturally from non-monotone logics.

The connection works like this. In a monotone logic, the collection of premise-sets that entail a given conclusion is "upward closed" — if a small set of premises works, any larger set works too. These upward-closed families have the structure of a genuine topology. But in a non-monotone logic, adding premises can break conclusions, so the premise-sets are *not* upward closed. The resulting structure is merely quasi-topological.

This means that the gap between monotone and non-monotone reasoning — between classical logic and dream logic — has a precise geometric character. Non-monotone reasoning lives in spaces where you can't freely combine observations, because observations from inconsistent contexts may not be jointly coherent.

## The Dream Defect

This geometric perspective leads to a natural question: how far is a given quasi-topology from being a genuine topology? Mathematicians have begun measuring what might be called the "dream defect" — the degree to which a reasoning system fails the union axiom.

A concrete example illuminates the idea. Consider the collection of sets that are either finite, empty, or everything. This collection is closed under intersection (the intersection of two finite sets is finite) but not under arbitrary union (infinitely many finite sets can have an infinite union that isn't everything). The "dream defect" captures exactly this gap.

Systems with zero dream defect are classical — they reason monotonically, their spaces are topological, and contradictions explode. Systems with positive dream defect are "dreamy" — they tolerate contradictions, retract beliefs, and inhabit spaces where the geometry itself forbids certain combinations.

## Dream Depth

Within Belnap's four-valued framework, we can measure how "dreamlike" a particular state of beliefs is. The *dream depth* counts how many propositions carry contradictory evidence — how many things are simultaneously true and false.

A dream depth of zero means classical reasoning: every proposition is either definitely true, definitely false, or unknown. Maximum dream depth means total contradiction — every proposition is both true and false simultaneously. And yet, even at maximum dream depth, the system doesn't collapse. Different propositions can still be distinguished by their logical relationships, even when all carry contradictory evidence.

This is the profound insight: contradiction is not the opposite of structure. Even in the most impossible of dream worlds, logical relationships persist. Conjunction still means "both," disjunction still means "either," and negation still swaps perspectives. The connectives don't care whether the values they operate on are "both true and false" — they process whatever they receive, maintaining the architecture of reasoning even when its contents are impossible.

## Implications Beyond Mathematics

The mathematics of dream logic has applications far beyond pure theory. In artificial intelligence, non-monotone reasoning is essential for systems that must revise beliefs as new information arrives — which is to say, all realistic AI systems. Database management requires frameworks that gracefully handle contradictory entries without crashing. And in philosophy, dream logic offers formal tools for analyzing the structure of impossible fictions, counterfactual reasoning, and the phenomenology of altered states of consciousness.

Perhaps most intriguingly, dream logic suggests that the rigidity of classical reasoning — its insistence that contradictions annihilate everything — is not a feature but a limitation. The universe of possible reasoning systems is far richer than the classical tradition imagined. Some of those systems tolerate impossibility, retract beliefs, and inhabit non-standard geometries. And some of them might be better models of how minds actually work — especially the mind at rest, dreaming in the dark, building worlds that are impossible and yet somehow coherent.

The next time you wake from a dream where your dead grandmother was simultaneously a river and a theorem, remember: there is now a mathematics for that. And it is beautiful.

---

*This article describes recent work formalizing paraconsistent and non-monotone logics, connecting them to quasi-topological spaces. The key results include proofs that Belnap's four-valued logic resists explosion, that skeptical consequence relations are genuinely non-monotone, and that the gap between monotone and non-monotone reasoning has a precise topological character.*
