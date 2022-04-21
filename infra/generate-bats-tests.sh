#!/usr/bin/env bash

bats_testfile="infra-tests.bats"
echo -e "#!/usr/bin/env bats\n" > ${bats_testfile}

for dir in infra/generic/*/ ; do
  CUSTOM_POLICY_ID=`yq eval '.metadata.id' ${dir}/policy.yaml`
  for passing in ${dir}pass*.tf ; do
    cat <<EOT >> ${bats_testfile}
@test "[PASSCHECK] ${CUSTOM_POLICY_ID}: ${passing}" {
    echo "[PASSCHECK] ${CUSTOM_POLICY_ID}: ${passing}"
    checkov --framework terraform -f ${passing} --external-checks-dir ${dir} --check ${CUSTOM_POLICY_ID}
}
EOT
  done
  for failing in ${dir}fail*.tf ; do
    cat <<EOT >> ${bats_testfile}
@test "[FAILCHECK] ${CUSTOM_POLICY_ID}: ${failing}" {
    echo "[FAILCHECK] ${CUSTOM_POLICY_ID}: ${failing}"
    ! checkov --framework terraform -f ${failing} --external-checks-dir ${dir} --check ${CUSTOM_POLICY_ID}
}
EOT
  done
done
