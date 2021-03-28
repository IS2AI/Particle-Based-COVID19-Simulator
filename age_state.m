function ages = age_state(age_distr, age_groups)
ages = [];
for ind=1:length(age_distr)
    temp = ones(age_distr(ind), 1) * age_groups(ind);
    if ind==1
        ages = temp;
    else
        ages = [ages; temp];
    end

% randomly shaffle the array
ages = ages(randperm(numel(ages)));

end