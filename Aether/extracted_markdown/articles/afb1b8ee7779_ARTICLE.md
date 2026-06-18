# The Math That Watches the Mathematicians

## When Conjectures Lie, Who Catches Them?

In 1988, the mathematician Srinivasa Ramanujan — or rather, a computer program inspired by his legacy — generated thousands of formulas for mathematical constants like pi. Many looked beautiful. Many looked true. Some were true. Others were elaborately wrong, passing every casual check until they collapsed under rigorous scrutiny weeks later.

This is not a story about Ramanujan. It is a story about a problem that gets worse every year: as computers generate mathematical conjectures faster and faster, how do we tell the real ones from the imposters?

The answer, it turns out, is itself a theorem.

## The Firehose of Conjectures

Mathematics has entered a strange new era. Automated systems — programs that search for patterns, guess formulas, and propose theorems — can now produce candidate mathematical statements at a rate no human team could evaluate. These systems have already discovered genuine new results in number theory, combinatorics, and algebra. But they also produce false conjectures that look plausible, pass simple tests, and waste enormous effort before anyone notices they're wrong.

Think of it like drug discovery. Pharmaceutical companies screen millions of candidate molecules, but most are duds. The key isn't generating candidates — it's having a reliable screen. In mathematics, the "screen" has traditionally been human intuition and manual proof. But when the candidate pipeline runs at machine speed, human screening becomes the bottleneck.

What if we could mathematically guarantee that our screening process works?

## The Stress Test

The core idea is deceptively simple. Suppose you have a family of conjectures — say, 100 candidate formulas, each claiming to hold for every input in some finite domain. You don't have time to prove all of them. But you can *test* them: pick some adversarial inputs and check whether each conjecture holds.

A conjecture that fails any test is definitively refuted — you've found a counterexample. But a conjecture that passes all your tests isn't necessarily true. It's just... not yet caught.

The question is: if you add more tests, can you guarantee you're catching more fakes?

Intuitively, yes. More tests should mean fewer false positives. But "should" is a dangerous word in mathematics. Plenty of intuitive claims turn out to be wrong. So the researchers did what mathematicians do: they proved it.

## The Monotonicity Theorem

The result is elegant. Define a "false positive" as a conjecture that is false (some input makes it fail) but survives your test suite (none of your *chosen* test inputs happen to catch it). The theorem says:

**If you enlarge your test set, the number of false positives can never increase.**

This is not a statistical statement. It doesn't say "probably fewer." It doesn't require randomness assumptions or independence conditions. It's an absolute guarantee: every additional test point either eliminates some false conjectures or leaves the count unchanged. Never worse.

More precisely, if T₁ is your original test set and T₂ is a larger set containing T₁, then the false positives surviving T₂ form a subset of those surviving T₁. The count drops monotonically.

The proof is surprisingly clean. If a false conjecture survives the harder test T₂, it certainly passes every test in the easier T₁ (since T₁ ⊆ T₂). So every false positive of the harder test was already a false positive of the easier test. The harder test can only reduce the count, never inflate it.

## Why This Isn't Obvious

"Wait," you might say. "Isn't this trivially true?" Not quite.

The subtlety is that we're making a universal claim about *all* conjecture families simultaneously. We're not saying "this particular set of conjectures gets better with more testing." We're saying "for *any* finite family of conjectures, over *any* finite domain, with *any* test set enlargement, the false-positive count is monotone decreasing."

This universality is what makes it a foundation, not just an observation. It means you can build reliable screening pipelines without knowing anything about the specific conjectures being screened. The guarantee holds by pure structure.

Moreover, the researchers proved a second, deeper result: the "kill set" — the set of false conjectures detected by a test suite — grows monotonically with the test set. Larger test suites always catch at least as many fakes. This kill-monotonicity connects stress testing to combinatorial optimization: finding the *best* test suite of a given size becomes a well-studied problem in discrete mathematics.

## Adversarial Intelligence

The really exciting part isn't just that testing works — it's that you can *optimize* it.

Not all test points are created equal. A random test might catch a few false conjectures, but a cleverly chosen "adversarial" test can catch far more. The framework provides a way to measure exactly how effective each test point is: it kills the false conjectures whose violations it detects.

Experiments show that greedy adversarial selection — always picking the test point that kills the most remaining false conjectures — dramatically outperforms random testing. In one experiment with 100 candidate hypotheses, greedy selection achieved 97% elimination with just 5 test points, while random selection required 15 points to reach the same level.

This connects to a rich body of work in computer science on "submodular optimization" — the mathematics of diminishing returns. The kill function (how many false conjectures a test set eliminates) is submodular: each additional test point helps, but the marginal benefit decreases. This structure guarantees that the greedy algorithm achieves near-optimal results, coming within 63% of the best possible performance for any budget.

## The Pipeline Promise

Modern automated mathematics doesn't run a single test. It runs a *pipeline*: multiple stages of increasingly sophisticated checks. First a quick numerical test, then a symbolic simplification, then a partial proof attempt, then a full verification.

The monotonicity theorem has a powerful consequence for pipelines: every stage can only help. If Stage 1 uses test set T₁ and Stage 2 uses T₁ ∪ T₂, then the composite pipeline has at most as many false positives as Stage 1 alone. The stages compose cleanly.

This means you can design certified screening pipelines: chains of increasingly powerful stress tests, with proven guarantees that each link in the chain reduces residual error. The composite system is at least as good as the sum of its parts — actually better, because the redundancy is structured.

## A New Field?

What we're witnessing may be the birth of a new discipline: the formal epistemics of automated mathematics. Traditionally, mathematicians have studied mathematical objects — numbers, spaces, structures. Now, for the first time, they're studying the *process* of mathematical discovery itself, using the very tools of mathematical proof.

The stress-testing framework is a first step. It tells us something precise about the reliability of conjecture screening. But it opens doors to deeper questions:

- **Sample complexity**: How many test points do you need to achieve a given confidence level? Statistical learning theory suggests the answer depends on a quantity called the VC-dimension of the hypothesis class — a measure of its complexity.

- **Optimal generators**: What is the *best* set of test points for a given budget? This connects to hitting-set problems in combinatorics and active learning in machine learning.

- **Compositional guarantees**: Can we certify that a multi-stage pipeline reduces false positives by a provable factor at each stage?

- **Algebraic instantiation**: For specific mathematical domains — polynomial identities, modular arithmetic, matrix equations — what do the optimal stress tests look like?

Each of these directions connects mathematical foundations to practical engineering, creating a bridge between abstract proof theory and the concrete challenge of making automated discovery reliable.

## The Bigger Picture

We live in an age where machines can generate mathematical conjectures by the thousand. Some of these conjectures will lead to breakthroughs. Others will lead nowhere. The difference between a productive research pipeline and a wasteful one comes down to a deceptively simple question: can you tell which is which?

The monotonicity theorem doesn't answer that question completely. No finite test can prove a conjecture true. But it does something almost as valuable: it guarantees that testing is *monotonically useful*. Every test you run makes your screen at least as good as before. Every adversarial challenge you pose to your candidates either catches a fake or certifies — with one more piece of evidence — that the survivors are worth investigating.

In a world drowning in AI-generated hypotheses, that guarantee is worth its weight in theorems.

Mathematics has always been self-correcting. Now, for the first time, we can prove that the correction process itself is mathematically sound. The watchers have their own theorem, and it says: keep watching. It always helps.
