package com.k8.josdkoperator;

import io.fabric8.kubernetes.client.KubernetesClient;
import io.fabric8.kubernetes.client.KubernetesClientBuilder;
import io.javaoperatorsdk.operator.Operator;
import io.javaoperatorsdk.operator.api.reconciler.Reconciler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;

@Slf4j
@SpringBootApplication
public class JosdkOperatorApplication {

    public static void main(String[] args) throws Exception {
        ApplicationContext context = SpringApplication.run(JosdkOperatorApplication.class, args);
        KubernetesClient client = new KubernetesClientBuilder().build();

        Operator operator = new Operator(overrider ->
            overrider.withKubernetesClient(client)
        );

        operator.register(new WebPageReconciler(client));
        operator.start();
    }
}

