function [H,b,B,Hs] = mean_prep(gp,x,xs)
% MEAN_PREP    Calculates help terms needed in inference with mean function
%
%     Description
%	  [H,b,B,Hs] = mean_prep(gpmf,x) takes in gp structure,
%	  test and training inputs. Returns base functions' values evaluated at
%     training inputs x and test inputs xs in matrices H and Hs 
%     (corresponding order),  base functions' weigths' prior mean 
%     vector b and prior covariance matrix B.
%
% Copyright (c) 2010 Tuomas Nikoskinen

% This software is distributed under the GNU General Public
% License (version 2 or later); please refer to the file
% License.txt, included with the software, for details.
    

        % Prepare variables
        Hapu = cell(1,length(gp.meanf));
        dimcount=0;
        if ~isempty(xs)
            Hapu2 = cell(1,length(gp.meanf));
        end
        for i=1:length(gp.meanf)
            gpmf=gp.meanf{i};
            % base functions' values
            Hapu{i}=feval(gpmf.fh_geth,gpmf,x);
            if ~isempty(xs)
                Hapu2{i}=feval(gpmf.fh_geth,gpmf,xs);
            end
            
            if i==1
                b=gpmf.p.b';
                Bvec=gpmf.p.B;
            else                        
                b=cat(1,b,gpmf.p.b');               % gather prior means in one vector
                if length(gpmf.p.B)>1               % gather prior covariances in one vector
                    Bvec=cat(2,Bvec,gpmf.p.B{:});
                else
                    Bvec=cat(2,Bvec,gpmf.p.B);
                end
            end
            [dim nouse] = size(Hapu{i});
            dimcount=dimcount+dim;          % amount of input dimensions
        end
        % Gather base functions' values in one matrix
        H = cat(1,Hapu{1:end});
        % Gather prior covariances in one matrix B
        if ~iscell(gp.meanf{1}.p.B)                      
            if length(gp.meanf{1}.p.B)==1              
                B=diag(Bvec);                       % scalar values
            else
                B=reshape(Bvec,dimcount,dimcount);  % vector values
            end
        else
            if length(gp.meanf{1}.p.B(1))==1
                B=diag(Bvec);                       % scalar values
            else
                B=reshape(Bvec,dimcount,dimcount);  % vector values
            end
        end
        if ~isempty(xs)
            Hs = cat(1,Hapu2{1:end});
        end
end