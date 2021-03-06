# markerDataCleaning

TO DO:

naiveDistances
--------------
Reconstruct: it doesn't work very well. The same reconstruction on the same frames returns different results each time. Why? Outliers remain even after reconstruction.
Alos, sometimes a single bad marker will make other tightly coupled markers have low logL, so they are 'loose' in the optimization.
Generate good default weights for positions, based on marker scoring.
The function is TOO sensitive to position weights: 1-1.3 works well, although 1.3 starts giving convergence issues, 2-3 is unusable, eventhough I expect this to represent a 2-3mm std of position, meaning that 95% of samples will fall within +-10mm the measured position. Is it possible that there is an extra squaring somewhere that takes this to a 100mm 95% CI?

Reconstruct fast:
Perhaps reconstruct one missing marker at a time, assuming the other 'bad' ones as fixed? (key feature here is that because weights are binary, we either trust markers or we don't, there is no gray area).
Generate good default trusted/not-trusted classification.

Go over all permute functions and move the applicable ones to markerModel() to avoid code duplication. 
Deprecate naiveDistances.tryPermutations() if possible. 
Check if permuteModelLabels() can be done through tryPermutations() of training data onto reference model alone [unclear if this necessarily will lead to the best permutation according to validateMarkerModel()]

All
-------------
Incorporate Kalman onto reconstruct:
The idea is that for each frame:
1) We do a Kalman-like integration of our knowledge of the previous frame with the measurements in this frame. We obtain a best position estimate and its uncertainty. This requires training a dynamical model.
2) We do reconstruct() but using the results from the kalman integration as priors, instead of the measured position with some given weights by itself
3) After reconstruct() we need to be able to return an uncertainty/variance matrix for each marker to be used in the next frame (currently we just return the estimated position).

