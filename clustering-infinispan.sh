if [[ -n $JBOSS_PREPARE_URL ]] ; then
    echo "JBOSS_PREPARE_URL =${JBOSS_PREPARE_URL}" >> $INFO
    echo "Bring testsuite  from ${JBOSS_PREPARE_URL}"
    curl -ksf --show-error "${JBOSS_PREPARE_URL}" -o archive.zip
    unzip -q archive.zip
    rm archive.zip
    export WORKSPACE=$PWD
    export MAVEN_REPO_LOCAL=$WORKSPACE/maven-repo-local
    export JBOSS_DIST=$WORKSPACE/jboss-dist
fi


if [ "$INFINISPAN_SERVER_ZIP x" != " x" ] ; then
    mkdir infini
    cd infini
    curl -ksf --show-error "$INFINISPAN_SERVER_ZIP" -o infinispan.zip
    unzip -q infinispan.zip
    rm infinispan.zip
    cd *-server*
    export ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS -Dinfinispan.server.home.override=$PWD"

    cd ../..
fi

if [[ -z "${CLUSTER_PROFILES}" ]]; then
  export CLUSTER_PROFILES="ts.clustering.cluster.fullha.profile,ts.clustering.cluster.ha-infinispan-server.profile,ts.clustering.byteman.profile,ts.clustering.single.profile"
fi

./integration-tests.sh clean install -Dts.noSmoke -Dts.clustering -Dmaven.repo.local=$MAVEN_REPO_LOCAL -Dmaven.test.failure.ignore=true $ADDITIONAL_PARAMS -P"$CLUSTER_PROFILES" -Djboss.dist="$JBOSS_DIST" 
