Partials
========

A partial is a snippet of code that you can reuse in any page of your site.
This is particularly useful for repetitive sections, and for sections that may
make your files too large to manage.

Creating partials
-----------------

Put your partial file anywhere in the `layouts` folder, e.g.:

    / layouts/shared/sidebar.haml
    %div#sidebar
      %h2
        %span Sidebar
      .description
        %p This is a sidebar partial defined in a separate file.

In your site's files, you can invoke a partial through:

    / site/index.html.haml
    %h1 Partial:
    = partial 'shared/sidebar'

    %span End of partial.
    %span This is now text from index.html.

This will output:
    
    <h1>Partial:</h1>
    <div id='#sidebar'>
      <h2><span>Sidebar</span><h2>
      <div class='description'>
        <p>This is a sidebar partial defined in a separate file.</p>
      </div>
    </div>
    <span>End of partial.</span>
    <span>This is now text from index.html.</span>

Partials with local variables
-----------------------------

You can define a partial with some local variables that will be passed
to it by the caller.

    -/ layouts/shared/product.haml
    .product
      .title
        %h2= name
      .desc
      %p= description

In your files, call a partial by:
      
    # site/index.html.haml
    = partial 'shared/product', { :name => '5MP Camera CX-300', :description => 'This is a camera with an adjustable focal length and Bluetooth support.' }


