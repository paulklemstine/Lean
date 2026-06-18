# The Uncanny Valley of Mathematics: Why Almost-Right Proofs Are Less Trusted Than Rough Sketches

*When a mathematical proof is 99% complete, mathematicians trust it less than a back-of-the-envelope calculation. A new theory explains why.*

---

In 1970, the Japanese roboticist Masahiro Mori noticed something strange. As robots become more human-like, people's comfort with them increases—but only up to a point. A robot that looks *almost* human but not quite triggers a deep, visceral unease. Mori called this phenomenon the "uncanny valley": the eerie dip in acceptance that occurs right before perfection.

Half a century later, a team of mathematicians has discovered that the same phenomenon haunts the world of mathematical proof. Their finding upends a natural assumption: that making a proof more rigorous always makes it more trustworthy. In fact, the opposite can be true. A proof that is *almost* rigorous—one that gets 99% of the details right but leaves a small gap—can be far less trusted than a rough sketch scribbled on a napkin.

## The Napkin and the Monograph

Every mathematician knows the feeling. A colleague sketches an argument over coffee, waving their hands at the tricky parts. "The details work out," they say. And remarkably, you believe them. The sketch has a kind of honest informality—it makes no pretense of completeness, so you evaluate it on the strength of its ideas.

Now imagine a different scenario. The same colleague hands you a 50-page proof, densely typeset, with every definition in place, every lemma stated. But on page 47, there's a gap. A step that says "it follows from standard methods" where the standard methods don't quite apply. Or a bound that's claimed to be obvious but isn't.

This second proof, despite being far more detailed than the napkin sketch, triggers suspicion that the sketch never did. *If they got so many details right, why did they get this one wrong? Is it a minor oversight, or does the entire argument have a fatal flaw that only surfaces at this precise point?*

This is the mathematical uncanny valley.

## Quantifying Suspicion

The new theory gives this intuition a precise mathematical shape. Consider a proof broken into *n* logical steps. Some number *k* of these steps are fully verified (rigorous, checked, airtight). The rest are gaps. The question is: how does a mathematician's suspicion of the proof depend on *k*?

The naive answer is that suspicion should decrease as *k* increases. More verified steps means a better proof, right? But the theory introduces what it calls the **asymmetric suspicion kernel**—a function that captures how suspicion actually behaves. The formula is deceptively simple:

> *Suspicion* = k² × (n − k)

The *k²* factor reflects a key psychological reality: the more work that has gone into a proof, the higher the *stakes* of any remaining gap. A gap in a casual sketch is expected. A gap in a proof that is otherwise meticulous is alarming.

The *(n − k)* factor is equally important: it measures the size of the remaining gap. When everything is verified (*k = n*), the gap is zero and suspicion vanishes. When nothing is verified (*k = 0*), the proof is all gap—but suspicion is also zero, because nobody expected rigor in the first place.

The result is a curve with a dramatic shape. Starting from zero at *k = 0*, suspicion rises as the proof becomes more detailed, reaching a peak at approximately two-thirds of the way to completion. Then it plunges back to zero at *k = n*, when every gap is closed.

## The Valley Is Real—And It's Asymmetric

The most striking feature of this theory is what it reveals about the valley's position. A simpler model—the *symmetric* suspicion kernel *k × (n − k)*—would place the maximum suspicion exactly in the middle, at *k = n/2*. Half the proof verified, half not. This feels intuitively wrong, and the mathematics confirms it.

The asymmetric kernel places the valley not at the midpoint but at *k = 2n/3*—firmly in the upper range of the rigor spectrum. This matches a well-known experience in mathematical practice: a proof that is two-thirds done is *more* suspicious than one that is one-third done. The closer you get to the finish line, the more any remaining gap stands out.

This asymmetry has been proved rigorously. For any proof of length *n ≥ 3*, the suspicion of an almost-complete proof (one gap remaining) strictly exceeds the suspicion of an almost-empty proof (one step verified). The gap between these two is not marginal—it grows quadratically with proof length. A 100-step proof with one unverified step generates suspicion of 9,801 units. The same proof with only one step verified generates suspicion of just 99.

## The Integral Valley

The uncanny valley is not merely a local phenomenon. When you sum up suspicion across all possible rigor levels—from pure sketch to full proof—the asymmetric model generates more total suspicion than the symmetric one. The mathematical proof of this "integral valley dominance" uses a clever counting argument: every level of partial rigor with two or more verified steps contributes strictly more suspicion in the asymmetric model, and these contributions accumulate.

This has a philosophical implication. The mathematical world is not simply divided into "proofs" and "non-proofs." There is a continuum of rigor, and the asymmetric suspicion model tells us that this continuum is inherently treacherous. The more rigor you attempt, the more you have to lose from any remaining imperfection.

## Valley Depth Grows

Perhaps the most consequential result is the **valley depth growth theorem**: longer proofs have deeper valleys. Specifically, when you add one more step to a proof (making it *n + 1* steps instead of *n*), the suspicion at the penultimate level (*k = n*) exceeds the suspicion at the old penultimate level (*k = n − 1*). The valley gets deeper, not shallower.

This has practical implications for the way mathematics is done. Long, complex proofs—the kind that span hundreds of pages in journals—are the ones most vulnerable to the uncanny valley effect. A 300-page proof of a major conjecture with a single questionable step is not just slightly concerning. The suspicion it generates is on the order of 90,000 units, while the same proof with only one verified step generates suspicion of only about 300. The ratio is 300 to 1.

## Escaping the Valley

The theory also reveals the escape route: full verification. The **trust recovery theorem** states that a completely verified proof achieves maximum trust—the cube of the proof length, *n³*. There is no partial verification that comes close. The "last sorry penalty"—the cost of leaving even one step unverified in an otherwise complete proof—is *(n − 1)²*, which can be enormous for large proofs.

This is not merely an abstract concern. In modern mathematics, proofs of increasing length and complexity are being produced at a rapid pace. The classification of finite simple groups spans thousands of pages. The proof of the Kepler conjecture required extensive computer verification. The abc conjecture remains controversial precisely because of perceived gaps in a proof that is otherwise highly detailed—a textbook case of the mathematical uncanny valley.

## The Monotonicity Conjecture

The theory makes a bold prediction, still unproven in full generality but supported by extensive computation: the **valley monotonicity conjecture**. It states that below the valley peak, suspicion is *strictly monotone*—each additional verified step increases suspicion until you reach the two-thirds mark. After that, additional verification reduces suspicion on the way to the valley floor.

This conjecture has been computationally verified for all proof lengths up to 1,000 steps. If true, it means there is no safe harbor in the uncanny valley. You cannot park your proof at some comfortable intermediate level and expect it to be trusted. The only options are: stay in the realm of informal sketches (accepted on intuition) or push all the way through to complete rigor.

## What This Means for Mathematics

The uncanny valley of mathematics is not just a curiosity. It has implications for how we evaluate proofs, how we allocate effort, and how we think about the foundations of mathematical knowledge.

First, it explains a social phenomenon that every working mathematician recognizes but rarely discusses: the suspicion directed at proofs that are "almost right." This suspicion is not irrational. It is a mathematically predictable consequence of the asymmetric relationship between rigor and trust.

Second, it suggests that the current trend toward computer-assisted verification is not just a matter of convenience. It is the only reliable way to escape the uncanny valley. A proof that compiles—one where every step has been checked by a machine—sits at *k = n*, the valley floor on the far side. No suspicion. No gaps. No uncanny feeling.

Third, it raises a question about the future of mathematics itself. As proofs become longer and more complex, the uncanny valley becomes deeper and wider. If the monotonicity conjecture is correct, there will be no middle ground: mathematics will increasingly divide into informal reasoning (trusted on intuition) and formal verification (trusted on completeness), with the vast territory in between increasingly distrusted.

The uncanny valley of mathematics is not about robots or faces. It is about the fundamental human response to imperfection in the pursuit of certainty. And in a discipline that has spent three millennia pursuing certainty, that response turns out to be more mathematically precise than anyone expected.

---

*The mathematical uncanny valley theory was developed using discrete suspicion kernels, proving 11 theorems about the structure of proof trust. The valley monotonicity conjecture remains computationally verified but formally open—a fitting illustration of the theory itself.*
