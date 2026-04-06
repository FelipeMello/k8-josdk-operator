package com.k8.josdkoperator;

import com.k8.josdkoperator.customresource.WebPage;
import com.k8.josdkoperator.customresource.WebPageStatus;
import io.fabric8.kubernetes.api.model.*;
import io.fabric8.kubernetes.api.model.apps.Deployment;
import io.fabric8.kubernetes.client.KubernetesClient;
import io.javaoperatorsdk.operator.ReconcilerUtilsInternal;
import io.javaoperatorsdk.operator.api.reconciler.Context;
import io.javaoperatorsdk.operator.api.reconciler.ControllerConfiguration;
import io.javaoperatorsdk.operator.api.reconciler.Reconciler;
import io.javaoperatorsdk.operator.api.reconciler.UpdateControl;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.time.Duration;
import java.util.Map;

@Slf4j
@AllArgsConstructor
@ControllerConfiguration
public class WebPageReconciler implements Reconciler<WebPage> {

    private KubernetesClient client;

    @Override
    public UpdateControl<WebPage> reconcile(WebPage webPage, Context<WebPage> context) {
        client.configMaps().resource(desiredConfigMap(webPage)).serverSideApply();
        client.services().resource(desiredService(webPage)).serverSideApply();
        client.apps().deployments().resource(desiredDeployment(webPage)).serverSideApply();

        log.info("Reconciled WebPage: {}/{}", webPage.getMetadata().getNamespace(), webPage.getMetadata().getName());
        webPage.setStatus(new WebPageStatus());
        webPage.getStatus().setReady(true);

        return UpdateControl.patchStatus(webPage).rescheduleAfter(Duration.ofSeconds(30));
    }

    private ConfigMap desiredConfigMap(WebPage webPage) {
       ConfigMap configMap = new ConfigMapBuilder()
                .withNewMetadata()
                .withName(webPage.getMetadata().getName())
                .withNamespace(webPage.getMetadata().getNamespace())
                .endMetadata()
                .addToData("index.html", webPage.getSpec().getHtml())
                .build();
        configMap.addOwnerReference(webPage);
        return configMap;
    }

    private Service desiredService(WebPage webPage) {
        Service service = new Service();
        service.setMetadata(webPage.getMetadata());
        service.getSpec().setSelector(Map.of("app", webPage.getMetadata().getName()));
        service.addOwnerReference(webPage);
        return service;
    }

    private Deployment desiredDeployment(WebPage webPage) {
        Deployment deployment = ReconcilerUtilsInternal.loadYaml(Deployment.class, getClass(), "deployment.yaml");
        String deploymentName = webPage.getMetadata().getName();
        deployment.setMetadata(webPage.getMetadata());
        deployment.getSpec().getTemplate().getMetadata().setLabels(Map.of("app", webPage.getMetadata().getName()));
        deployment.getSpec().getTemplate().getMetadata().setLabels(Map.of("app", deploymentName));
        deployment.getSpec().getTemplate().getSpec().getVolumes().getFirst()
                .setConfigMap(new ConfigMapVolumeSourceBuilder().withName(deploymentName).build());
        return deployment;
    }
}
