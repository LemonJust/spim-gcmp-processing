function Minv=ants2affine(Path) 
% DESCRIPTION : takes a mat file produces by the ANTs registration and turns it into an
% affine transformation matrix for the row vectors
%INPUT: path to the mat file including the filename
%
% by Anna Nadtochiy @Fraser lab

% disp(' ')
% disp('Input : ')
% load mat file from ANTs
Trans = load(Path);
Names =  fieldnames(Trans);
A = Trans.(Names{1});
matrix = transpose(reshape(A(1:9),3,3));
m_Translation = A(10:12);
m_Center = Trans.(Names{2});
% compute offset (see ANTs documentation for details)
offset = zeros(3,1);
for i = 1:3
    offset(i) = m_Translation(i) + m_Center(i);
    for j = 1:3
        offset(i) = offset(i) - matrix(i,j)*m_Center(j);
    end
end
% compose matrix
M(1:3,1:3) = matrix;
M(4,1:3) = zeros(1,3);
M(1:3,4) = offset;
M(4,4) = 1;
Minv = inv(M);
Minv = Minv.';
% 
% disp(' ')
% disp('Paste into Synapse Database : ')
% disp(['[[',num2str(Minv(1,1)),',',num2str(Minv(1,2)),',',num2str(Minv(1,3)),',',num2str(Minv(1,4)),'],'...
%         '[',num2str(Minv(2,1)),',',num2str(Minv(2,2)),',',num2str(Minv(2,3)),',',num2str(Minv(2,4)),'],'...
%         '[',num2str(Minv(3,1)),',',num2str(Minv(3,2)),',',num2str(Minv(3,3)),',',num2str(Minv(3,4)),'],'...
%         '[',num2str(Minv(4,1)),',',num2str(Minv(4,2)),',',num2str(Minv(4,3)),',',num2str(Minv(4,4)),']]'])
end
