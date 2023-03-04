function [indices] = getindices(T)


idxChatPos = find(T.ChAT==1);
idxChatNeg = find(T.ChAT==0);
idxChatUnk = find(isnan(T.ChAT));

idxBLAPos = find(T.BLA==1);
idxBLANeg = find(T.BLA==0);
idxBLAUnk = find(isnan(T.BLA));

idxChatPosBLAPos = intersect(idxChatPos,idxBLAPos);

idxChatNegBLAPos = intersect(idxChatNeg,idxBLAPos);
idxChatNegBLAPos2 = intersect(idxChatUnk,idxBLAPos);
idxChatNegBLAPos = [idxChatNegBLAPos; idxChatNegBLAPos2];

idxChaTPosBLANeg = intersect(idxChatPos,idxBLANeg);

idxChaTPosBLAUnk = intersect(idxChatPos,idxBLAUnk);

idxOther = idxChatNeg;
idxOther(ismember(idxChatNeg,idxBLAPos)) = [];


indices.CP = idxChatPos;
indices.CN = idxChatNeg;
indices.CU = idxChatUnk;
indices.BP = idxBLAPos;
indices.BN = idxBLANeg;
indices.BU = idxBLAUnk;
indices.CPBP = idxChatPosBLAPos;
indices.CNBP = idxChatNegBLAPos;
indices.CPBN = idxChaTPosBLANeg;
indices.CPBU = idxChaTPosBLAUnk;
indices.CNBN = idxOther;



