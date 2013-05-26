# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.Kent ||= {}

window.Kent.Feed =
  init : ->
    $('#refresh-feed').on 'click', (e) =>
      e.preventDefault()

      refresSpinner = $('#refresh-feed').find('img')
      refresSpinner.addClass('spin')
      feed_id = $('#refresh-feed').parents('.feed').data('feed-id')

      xhr = @refreshFeed(feed_id)
      xhr.done ->
        refresSpinner.removeClass('spin')

    $('#refresh-feeds').on 'click', (e) =>
      e.preventDefault()

      @refreshAll()

    $('.post-link').on 'click', ->
      post = $(@).parents('.post')
      post_id = post.attr('id').replace('post-', '')

      $.ajax
        dataType : 'script'
        type : 'POST'
        url : "/posts/#{post_id}/mark_as_read"
      

    $('.post-date').on 'click', ->
      post = $(@).parents('.post')
      post_id = post.attr('id').replace('post-', '')

      unless post.find('.post-content').hasClass('collapsed')
        $.ajax
          dataType : 'script'
          type : 'POST'
          url : "/posts/#{post_id}/mark_as_read"

      post.find('.post-content').toggleClass('collapsed')

    @initPostsCounterUpdater()

  refreshAll : ->
    for feed_id in @feedIdsFromList()
      @refreshFeed(feed_id)
  
  refreshFeed : (feed_id) ->
    if $('#refresh-feed').length > 0
      refresSpinner = $('#refresh-feed').find('img')
    else
      refresSpinner = $('#refresh-feeds').find('img')

    refresSpinner.addClass('spin')

    $.ajax
      dataType : 'script'
      type : 'POST'
      url : "/feeds/#{feed_id}/import_posts"
      complete : ->
        refresSpinner.removeClass('spin')

  feedIdsFromList : ->
    $('#feeds_list').find('.feed-item').map((index, item) ->
      $(item).data('feed-id')
    ).toArray()

  initPostsCounterUpdater : ->
    Uatu.on 'update-posts-counter', (feed_id, counter) ->
      $("[data-feed-id=#{feed_id}]").find('.feed-post-counter').text(counter)

  appendPosts : (posts) ->
    if posts.length == 0
      console.log 'No posts found'
    else
      template = $('#template-post').text()

      posts = posts.reverse()

      for post in posts
        post.published_at = moment(new Date(post.published_at).toUTCString()).format('YYYY-MM-DD HH:mm')
        post.published_at_ago = moment(new Date(post.published_at).toUTCString()).fromNow()
        if post.read
          post.toggle_read_path = "/posts/#{post.id}/mark_as_unread"
          post.toggle_read_text = "Mark as unread"
        else
          post.toggle_read_path = "/posts/#{post.id}/mark_as_read"
          post.toggle_read_text = "Mark as read"

        content = Mustache.render(template, post)

        $("#feed-posts-#{post.feed_id}").prepend content