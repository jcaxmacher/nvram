---
title: "Agile, Dev(Sec)Ops, SRE, et al. - Finding the common thread for business"
linktitle: "Agile, Dev(Sec)Ops, SRE, et al. - Finding the common thread for business"
date: 2019-04-04
author: "Jeremy Axmacher"
draft: false
thumbnail: "/images/change.jpg"
thumbnailattribution: "SomeDriftwood/Flickr/CreativeCommons"
tags: ["agile", "devops", "sre", "supply and demand", "learning organizations"]
---

In the past three decades, the Information Technology industry has seen the rise of many new methodologies and movements that purport to deliver certain benefits like improved team communication & coordination, directional agility, production quality & consistency, and faster customer feedback, to name a few.  While these methodologies have differing foci, I believe that fundamental value provided to a business is the same for all of them.  At their core, they enable businesses to use technology to move the demand curve for their product.  Of course, there are human benefits that are a core element of these methodologies, but our focus here is on why these matter for businesses.

> At their core, Agile, Dev(Sec)Ops and SRE enable businesses to use technology to move the demand curve for their products.

## Economics and the Internet

In the pre-internet and early internet days, if a business wanted to move the demand curve for its product, it would turn to sales and marketing.  Sales and Marketing did the product apologetics that educated the market thereby changing the number of consumers of a product or the distribution of tastes of consumers.  This is true today as well, but it's not the only lever a business has. Before internet-era delivery of IT services, the best IT could do was to increase the technical efficiency of producing the product which moved the supply curve to the right because the cost of producing the product had been lowered.  The long release time and the delivery format for software and related services meant that when a product came to market either it was a natural fit, the fit needed assistance through consumer education (i.e., Sales and Marketing), or it bombed.  Further, many organizations found it difficult to achieve technical efficiency.

Then, in the late 1990s and early 2000s, the internet began to take the shape that we know today--- businesses and people using high speed data connections to deliver information and services much faster than before.  It caused tremendous growth in the quaternary sector of the economy (i.e., knowledge-based economic activity) in the U.S and other developed nations.  It opened a new path.  If a business can build and deliver new features in their product (or a new product entirely) very quickly, then that business has the opportunity to not just use technical efficiency to move the supply curve, but to also move the demand curve by iteration and exploration toward better product-market fit.  This is very basic economics, but shows why the increasing pace of business and the methodologies that enable that pace are so important.

![Shifting the demand curve to the right increases both the equilibrium price and quantity](/images/shifting-demand-curve.png)
*Shifting the demand curve to the right increases both the equilibrium price and quantity demanded for a particular product*

## So what are Agile, DevSecOps and SRE?

As mentioned earlier, the big names in IT methodologies focus on different areas and advocate different means for improvement.  If you're in the IT industry you'll be familiar with these terms, but it never hurts to ensure we have a shared language.  I'll briefly describe Agile, DevOps and SRE.

Agile, at least [as it was initially conceived](https://agilemanifesto.org/),  is a movement geared toward improving software development by 1) improving collaboration within the teams building software, 2) focusing on delivering working software in very short, regular intervals, 3) getting customer input throughout the development process and 4) being very responsive to changes in direction.  Agile took some influence from Lean, which itself came from a study of the manufacturing process at Toyota.  The Lean ideas of identifying & eliminating waste and continuous improvement have found their way into various flavors of Agile.  Agile methodologies help with broken communication between developers, stakeholders and customers.

DevOps sprung up after Agile and put further focus on collaboration between teams connected to delivery of value through IT.  In the case of DevOps methodologies, the target is the communication and coordination between developers and operations.  The phrase "shift left" was coined to capture the need for operational concerns--- like how do we deploy and support the software being developed ---"shift" to earlier in the development process.  DevSecOps continued along the same line as DevOps with the goal of bringing security concerns earlier into the software development and deployment processes.  Because there is no DevOps manifesto, there have been many attempts to define exactly what it is.  Some in the community have gone so far as to say "[it's like Kung Fu--- if you are a practitioner, you know it when you see it.](https://www.youtube.com/watch?v=uK0vmT0QYfI)"  Practices that tend to go along with DevOps (and have significant tooling/automation components) like Continuous Integration and Continuous Delivery/Deployment, are sometimes conflated with DevOps itself.

Site Reliability Engineering (SRE) is Google-flavored methodology for delivering and running software that has been described as "[a specific implementation of DevOps with some idiosyncratic extensions](https://landing.google.com/sre/sre-book/chapters/introduction/#devops-or-sre-8OS8HmcX )"  Two things, from my perspective, make it notably different from DevOps.  The first is the specific way SRE proposes to resolve the differing objectives of Development and IT Operations (see [error budgets](https://landing.google.com/sre/sre-book/chapters/introduction/#pursuing-maximum-change-velocity-without-violating-a-services-slo-pWsJh2iL)).  The second is the greater focus on automation of operational activities by software engineers/developers whose role is a superset of the traditional Ops/sysadmin role.

These days Agile, Dev(Sec)Ops and SRE each come with a significant set of practices and tooling.  Though SRE is the only one that explicitly called for engineering/automation from its beginning, there is broad agreement that significant tooling is involved in implementing any one of them.  Many tooling vendors these days attempt to sell Agile/DevSecOps/SRE, when what they are really selling is a tool that will help with one of the processes or practices associated with the methodology.  Fundamentally, none of these methodologies can be implemented without establishing shared goals between teams and setting up forcing functions for collaboration and communication.  In practice, that is unlikely to happen in a large organization without organizational restructuring to align priorities.

## Practical Application

So, where do you begin if you want to leverage technology and modern methodologies to move the demand curve for your business?  Start with the [theory of constraints](https://en.wikipedia.org/wiki/Theory_of_constraints). Identify your goal and identify the limiting factor in achieving that goal.  This can be very difficult.  Bottlenecks are not often readily apparent.  Be sure that your goal is connected with a top line metric about your business-- e.g., are we retaining customers? is customer engagement with our product increasing? are we converting more leads to customers? how are our customer feedback metrics?  Once you have the limiting factor, focus on improving that using the methodology that fits the constraint.

Do not try to optimize areas that are commodities.  This means that _fill-in-the-blank_ methodology should not be used for patching servers that are running line-of-business applications-- by all means apply automation, but the goal is driving cost down and increasing consistency, not changing consumer demand.  You can tell if something should be a commodity to your business by the expectations people have around that thing.  Do your employees just expect it to work?  Then it's a commodity.  Once you know that, you should ask yourself if that is work you want to be doing at all.  Why not buy that from a vendor who makes their money doing that thing and can offer you their economies of scale?

## Conclusion

To summarize, the internet has brought a sea change to businesses and we are not even close to the end of the effects of that change. Businesses that can capitalize on that by enabling continuous re-fitting of their products to the market have a much higher chance of succeeding.  There are a number of IT methodologies that can support a business' "digital transformation," but they all provide the same underlying value proposition.  There's no need to drink the Kool-Aid on just one-- it's better to focus on [becoming a learning organization](https://en.wikipedia.org/wiki/Learning_organization) and apply the best practices for your constraints.


<style>
img {
  max-height: 300px;
  display: block;
  margin: auto;
  }
p > img + em {
  max-width: 80%;
  display: block;
  margin: auto;
  }
</style>
