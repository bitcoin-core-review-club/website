---
layout: topic
title: Branch and Bound (BnB)
---

## Notes

- How it works:
    - Deterministically searches the complete combination space to find an input set that will avoid the creation of a change output.
    - It performs a depth-first search on a binary tree where each branch represents the inclusion or exclusion of a UTXO, exploring inclusion branches first, and backtracking whenever a subtree cannot yield a solution.
    - It returns the first discovered input set that is an exact match for the funding requirement of the transaction. The qualifier “exact match” here refers here to an input set that overshoots the `nTargetValue` by less than the cost of a change output.
    - The BnB algorithm is not guaranteed to find a solution even when there are sufficient funds since an exact match may not exist.

<!-- uncomment to add
## History
-->
<!-- uncomment to add
## Resources
-->
