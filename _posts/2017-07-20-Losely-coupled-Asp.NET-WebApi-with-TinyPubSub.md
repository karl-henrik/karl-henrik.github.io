---
title:  'Losely coupled Asp.NET WebApi with TinyPubSub'
date:   2017-07-20 11:31:47 
categories: [architecture,TinyPubSub]
tags: [TinyPubSub,WebApi]
---

Building APIs can be tricky, what seemed like a straight forward easy project can three months down the road have turned into a change request ridden, feature creep hell hole. It's not your fault, you didn't know they also needed to update the legacy system every time someone placed an order and also tell Kim in accounting every time someone who had been a customer for more than ten years made a purchase. If your code is now filled with if/else and switch cases you may have fallen in a very common trap, your code were not loosely coupled. 

One the easiest ways of making sure my APIs are loosely coupled is to use the super simple [Publish/Subscribe pattern](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern). In its most simple form you have two types of objects Publishers and Subscribers. A publisher sends en message to a queue and a subscriber acts on the event. For large and complex applications I would probably use one of the high performance queues like Azure ServiceBus or EventHub. But what about when we are just doing a small project and can't be bothered with the plumbing and infrastructure of external SaaS solutions? 

When my friend and colleague [Johan Karlsson](http://www.johankarlsson.net) released [TinyPubSub](https://github.com/johankson/TinyPubSub) to make UI and app logic more loosely coupled in Xamarin apps I noticed that it had potential for doing the same for APIs. TinyPubSub is not much more than a dictionary of steroids. It keeps track of who is listening to what topic and allows for easy Pub/Sub without configuration and it keeps everything in memory.

With TinyPubSub you subscribe by calling the static method logically named Subscribe and tell it what to do and you are done.

```csharp
    //Trigger anytime, anything is published to "Topic"
    TinyPubSub.Subscribe("Topic", IDoCoolStuff());

    //Trigger anytime something is published with some content
    TinyPubSub.Subscribe("Topic", (x) => IDoCoolStuff(x));

```
Publishing is done in a very similar manner.

```csharp
    TinyPubSub.Publish("Topic", "This is some content");
```

Now that we know the basics about the TinyPubSub library, lets use it to build a loosely coupled Asp.Net WebAPI. The event emitter in this case will be a HTTP POST to our API but TinyPubSub could be used with any event emitter. 

Start by adding a new .NET Core Asp.NET project and select the WebAPI 2.0 Template to generate a simple API application.
![Visual studio create new project]({{site.url }}/Images/TPSLC-1st.png)

Install TinyPubSub from the package manager console.
> install-package Tinypubsub

Start coding by renaming the ValueController to OrderController. Add a folder called Observers and add two new classes called BillingObserver and ShippingObserver to that folder. Finally let's create an interface and call that IObserver.

Now that we have TinyPubSub installed we can update the BillingObserver, ShippingObserver and OrderController to look like the examples below.

```csharp
public class BillingObserver : IObserver
    {
        public BillingObserver()
        {
            TinyPubSub.Subscribe(Topics.Orders, (x) => BillOrderCommand(x));
        }

        public void BillOrderCommand(string order)
        {
            Debug.WriteLine("Billed: " + order);
        }
    }
```

```csharp
    public class ShippingObserver : IObserver
    {
        public ShippingObserver()
        {
            TinyPubSub.Subscribe(Topics.Orders, (x) => ShipOrderCommand(x));
        }

        private void ShipOrderCommand(string order)
        {
            Debug.WriteLine("Shipped :" + order);
        }
    }
```

````csharp
[Route("api/[controller]")]
    public class OrderController : Controller
    {
        [HttpPost]
        public void Post()
        {
            TinyPubSub.Publish(Topics.Orders,"A bit of event data");
        }
        
    }
````

Finally we need to initiate our observers. Edit the file Startup.cs

````csharp
 public class Startup
    {

        public List<IObserver> _observers = new List<IObserver>(); // <-- This is new

        public Startup(IHostingEnvironment env)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();
            Configuration = builder.Build();


            // Register observers
            _observers.Add(new BillingObserver()); // <-- So are these two lines
            _observers.Add(new ShippingObserver());
        }

        .... //Don't remove any other code the dots are just to show that there are more code below.
````

The last thing we need to do is, as you probably have spotted, add the Topics class. TinyPubSub topics are case sensitive so "orders" and "Orders" are not the same and can cause quite a bit of headache if you are not careful or if you are a team of people writing the software. To avoid this we will not use string defined topics but instead replace them with a class called Topics that assures everyone uses consistent topic names. 

````csharp
public static class Topics
{
    public static string Orders => "Orders";
}
````

Visual studio users who implement this can also use the reference function to quickly see what observers and publishers a specific topic has. 

![The reference functions]({{site.url }}/Images/TPSLC-2.png)


