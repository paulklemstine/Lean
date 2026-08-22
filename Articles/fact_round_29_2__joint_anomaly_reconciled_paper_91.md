# The Bug That Ate a Bit: How Arithmetic Decided a Scientific Dispute

## Two runs, one dataset, two answers

Somewhere in a data pipeline, two teams measured the same thing on the same data and got different numbers.

The quantity was a *mutual information*: how many bits you learn about one variable by observing another. One run said the two dials in the experiment shared $2.1314$ bits of information. A later rebuild of the same analysis, on the same population, said $0.5830$ bits. That is not a rounding disagreement. That is one analysis claiming a loud, clear signal and another claiming a faint whisper.

The usual way this argument ends is badly. Each side re-runs its code, each side finds its own code convincing, and the ledger records an unresolved anomaly. What actually happened is much more satisfying: the dispute was settled by *arithmetic*, and the argument that settled it turns out to be a small, sharp theory about a mistake that almost every experimental pipeline in the world is quietly at risk of making.

## The mistake: chaining labels into one number

Suppose each observation in your data carries two discrete codes. Call them $a$ and $b$: perhaps $a$ is which of four experimental arms the sample came from, and $b$ is which of nine outcome classes it landed in. You want to study the *pair* $(a,b)$ as a single categorical variable — the "joint label".

Almost everyone does this the same way. You pick a number $M$ — call it the **frame** — and you build

$$\pi(a,b) \;=\; a\cdot M + b .$$

With $M = 10000$ and codes $a = 3$, $b = 7$ you get the label $30007$. Read it back with your eyes and you can see the two components sitting side by side, $3$ and $0007$. It is a decimal filing system: the outer code goes in the high digits, the inner code in the low digits.

It works beautifully — as long as the low digits are wide enough to hold the inner code. If $b$ can be as large as $8$ but you chose $M = 3$, then the label $\pi(0,3) = 0\cdot 3 + 3 = 3$ and the label $\pi(1,0) = 1\cdot 3 + 0 = 3$ are *the same number*. Two genuinely different observations have been filed in the same drawer. Nothing crashes. No warning is printed. The analysis proceeds on a silently merged version of your data.

That is exactly what happened. The rebuild had used a $\cdot 10$ frame for a code that needed more room, nested inside a $\cdot 100$ frame for a six-valued code — and the digits overlapped.

## The width criterion, and why it is exactly right

The first thing to prove is the sharpest possible version of "wide enough".

> **Width Criterion.** Let the outer code range over $\{0,1,\dots,A-1\}$ and the inner code over $\{0,1,\dots,B-1\}$, with at least two outer values. The chaining $\pi(a,b) = aM+b$ is injective — that is, the label determines the pair — **if and only if** $B \le M$.

One direction is the schoolchild's argument for why decimal notation works: if $b < M$ then $\lfloor (aM+b)/M \rfloor = a$ and $(aM+b) \bmod M = b$, so the pair can be read straight back off the label. Division with remainder *is* the decoder.

The other direction is the important one, because it says the failure is not bad luck but a law. If $M < B$, then the two pairs $(0, M)$ and $(1, 0)$ are both legal, they are different, and both are labelled $M$. There is no data set on which a too-narrow frame is safe. The collision is baked into the arithmetic before the first observation arrives.

## How many drawers are left?

If you know a merge occurred, the next question is how bad it was. This too has an exact answer, and it is prettier than one might expect.

> **Exact Label Count.** With $A$ outer codes, $B$ inner codes, and a narrow frame $M \le B$, the set of labels actually produced is precisely the block of integers $\{0, 1, \dots, M(A-1)+B-1\}$ — no gaps. So the number of distinct labels reported is exactly
> $$M(A-1) + B,$$
> against $A\cdot B$ genuine pairs. Whenever $M < B$ and $A \ge 2$, this is strictly smaller.

The proof is a tiling picture. Each outer value $a$ contributes the interval $[aM,\, aM+B)$ of labels. Consecutive intervals start $M$ apart but are $B$ long, so when $M \le B$ they overlap — the strips slide over each other like roof shingles, and their union is one unbroken run from $0$ up to the top of the last strip, at $M(A-1)+B$.

Now the audited case. The population had $A = 4$ outer codes and $B = 9$ inner ones: $36$ genuine pairs. A width-valid frame keeps all $36$. The narrow $\cdot 3$ frame of the rebuild reports
$$3\cdot(4-1) + 9 = 18$$
labels. Exactly half. Thirty-six drawers collapse into eighteen, and the shape of the retracted reading — $36$ labels in the original, $18$ in the rebuild — is reproduced not by simulation but by a formula.

## From lost drawers to lost bits

Counting drawers is not yet the scientific claim. The claim was about information, measured in bits, so we need to know what merging does to entropy.

Write $H = -\sum_i w_i \log_2 w_i$ for the Shannon entropy of a set of weights, with the standard convention that an empty drawer contributes nothing. The right object turns out to be the **deficit** of a block: if a block of atoms with weights $w_1,\dots,w_n$ is collapsed into a single label carrying their total mass $S = \sum_i w_i$, the entropy destroyed is

$$D \;=\; \underbrace{\sum_i \bigl(-w_i \log_2 w_i\bigr)}_{\text{before}} \;-\; \underbrace{\bigl(-S \log_2 S\bigr)}_{\text{after}} \;=\; \sum_i w_i\bigl(\log_2 S - \log_2 w_i\bigr).$$

Written that way, three facts fall out.

**Merging always loses.** Every term is a nonnegative weight times $\log_2(S/w_i) \ge 0$, since no single atom can outweigh the block containing it. So $D \ge 0$: a coarsening can never manufacture entropy.

**Merging strictly loses if there was anything to lose.** If two distinct atoms in the block have strictly positive mass, then at least one term is strictly positive and $D > 0$. Entropy does not merely fail to rise; it genuinely falls.

**Merging never loses more than the block can hold.** A block of $n$ atoms carrying total mass $S$ loses at most $S\log_2 n$, because among all ways of splitting mass $S$ across $n$ atoms the uniform split is the most entropic. This is Gibbs' inequality in disguise — compare the actual weights with the uniform ones and the relative entropy between them, being nonnegative, is exactly the slack. And the bound is attained: a uniform block of $n$ atoms with total mass $1$ loses exactly $\log_2 n$.

A cautionary footnote deserves its own sentence, because it is the kind of thing that bites implementers. Gibbs' inequality — "relative entropy is nonnegative" — is *false* under the convenient convention $0\log 0 = 0$ unless one also demands absolute continuity: the comparison weights must not vanish where the real weights do not. Take the true weights $(\tfrac12, \tfrac12)$ and the comparison weights $(0, 1)$. Under the naive convention the relative entropy evaluates to $\tfrac12(\log_2\tfrac12 - \log_2 0) + \tfrac12(\log_2 \tfrac12 - \log_2 1) = \tfrac12(-1-0) + \tfrac12(-1) = -1 < 0$. The hypothesis is not decoration; it is load-bearing.

## The theorem that adjudicates

Now the two structural facts that actually decide who was right. They are stated for a joint population of pairs $(x,y)$ with nonnegative weights, where $x$ is the thing being labelled and $y$ is whatever the channel is being measured against. Write $I$ for the mutual information $H(\text{first marginal}) + H(\text{second marginal}) - H(\text{joint})$.

> **Encoding Invariance.** If a labelling of the first coordinate is injective, the mutual information is unchanged.

Relabelling is not analysis; it is renaming. Two clean, independent implementations that both satisfy the width criterion are computing the same functional of the same data through different notations, so they *must* agree to the last digit. That is why the clean-code cross-check reproducing $2.1314$ exactly is genuine evidence rather than a coincidence: exact agreement is what the theorem predicts, and near-agreement would have been a red flag.

> **Data-Processing Inequality for Label Merges.** *Any* labelling of the first coordinate — injective or not — can only decrease the measured mutual information: $I(\text{after}) \le I(\text{before})$.

The proof is the deficit calculus again, applied one fiber at a time. Collapsing a fiber destroys entropy in the joint distribution and in the first marginal, but the second marginal is untouched. The engine is a concavity statement: split a weight vector into a family of pieces, and the total deficit of the pieces never exceeds the deficit of their sum. So the entropy destroyed in the joint is at most the entropy destroyed in the marginal, and mutual information — marginal minus joint, in effect — can only drop.

Put the two together and the dispute is over before any data is examined:

> **The Reconciliation.** On one and the same population, a width-valid encoding reports the true value, and every other encoding reports at most that value.

Collision artifacts are **signed**. They cannot inflate a reading; they can only deflate it. When two runs on an identical population disagree and one of them is width-valid, the larger number is the admissible one and the smaller is the artifact. The original stands — $2.1314$ bits — and it stands for a reason that does not depend on trusting either team's code.

On the audited population one can make this fully quantitative without any data at all. The $36$ pairs, weighted uniformly, carry $\log_2 36 \approx 5.1699$ bits of label entropy. A width-valid frame preserves every one of them. The narrow $\cdot 3$ frame merges the pairs $(0,3)$ and $(1,0)$ into the single label $3$, and those two atoms alone force a loss of at least $\tfrac{1}{18}$ of a bit — so the narrow reading is *provably* strictly below the wide one, by a margin one can write down.

## An error bar for the error

A one-sided bound settles the direction of the discrepancy, but it does not say how big a discrepancy a merge can excuse. Without a ceiling, "collisions did it" becomes unfalsifiable — any gap whatsoever could be blamed on the encoding. So the other side of the bound matters just as much.

> **Collapse Ceiling.** If no label collects more than $k$ of the original classes, then a merge destroys at most $\log_2 k$ bits of label entropy, and at most $\log_2 k$ bits of mutual information — regardless of how large the population or how rich the channel.

In particular, **a two-to-one merge costs at most one bit**, always. And the contrapositive is the audit test one actually runs: if two readings of the same population differ by more than one bit, then some label must have swallowed at least *three* distinct classes. Pairwise merging cannot account for it, and if no such triple merge exists in the encoding, the two pipelines differ in something other than their labels — and you go looking for that something instead.

There is a sharper version still, which compares the two things a pipeline usually reports side by side:

> **Information lost never exceeds label entropy lost.** For any coarsening whatsoever, the drop in mutual information is bounded by the drop in the entropy of the relabelled variable.

That is a consistency check you can perform on a printed results table, with no access to the raw data and no re-run: two columns you already have, one inequality between them.

Applied to the audited case, the ceiling is concrete. Under the narrow $\cdot 3$ frame no label of the $4\times 9$ population collects more than three pairs, so the frame can destroy at most $\log_2 3 \approx 1.585$ bits. The reported readings — $2.1314$ against $0.5830$, a gap of $1.5484$ bits — sit just inside that ceiling. The collision story is *quantitatively admissible*; it clears its own bar with about four hundredths of a bit to spare. Had the gap been $2$ bits, the frame alone could not have been the culprit, and the reconciliation would have had to look elsewhere.

The sharper two-column test is more interesting still, and worth stating honestly. The reported label entropies were $4.6006$ bits for the width-valid reading and $3.6073$ for the rebuild — a drop of $0.9933$. The information drop was $1.5484$. Since information lost can never exceed label entropy lost under a single coarsening, the two rows cannot differ *only* by a merge of the joint label: something else in the rebuild's chain differed too. That is precisely what a diagnostic is for. It does not merely confirm the verdict; it tells you that the collapse happened at more than one stage, and points at where to look.

## Why any of this matters outside one ledger

The pattern generalizes far past one disputed row. Any time a pipeline packs several discrete fields into a single integer key — a hash, a group-by key, a stratum identifier, a sparse-matrix index, a bucket in a contingency table — it is chaining, and it is exposed to exactly this failure. The failure mode is the worst kind: silent, deterministic, reproducible, and *conservative-looking*. Because merges only lower measured information, the corrupted analysis looks cautious. It reports a weaker effect. Nobody's alarm goes off when an effect gets smaller; that is what everybody expects a careful reanalysis to do.

The remedy is embarrassingly cheap and now provably sufficient. Before running the experiment, check $B \le M$: the frame must dominate the inner alphabet. The width criterion is not a heuristic or a rule of thumb; it is exactly equivalent to the absence of collisions, which means a pipeline that passes it cannot have this bug and a pipeline that fails it certainly does. For multi-field keys the same criterion iterates into the familiar mixed-radix condition: each frame must exceed the product of the alphabet sizes below it.

And when a suspect pair of numbers is already in the record, the theory says what to do with them. Direction: the larger reading wins, if it is the width-valid one. Magnitude: the gap must fit under $\log_2 k$, where $k$ is the worst fiber of the offending encoding. Consistency: the information lost must not exceed the label entropy lost. Three tests, each a one-line inequality, each derivable from the same deficit calculus.

The reconciliation ended with the original number reinstated and the rebuild's row withdrawn. But the durable output was not the verdict. It was the discovery that a class of silent data-corruption bugs has an exact arithmetic signature, a signed direction of error, and a two-sided error bar — so that the next time two runs disagree, the argument can be settled by a criterion instead of by a re-run.

Decimal notation, it turns out, has a precondition. It is worth checking.
